#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2023 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.PermissionException do
  defexception message: "Access Denied",
               permission: nil,
               resource: nil,
               term: nil
  
  def to_term(e), do: {:error, e}
end

defmodule Noizu.ContextException do
  defexception message: "Context Exception",
               term: :other
  def to_term(e), do: {:error, e}
end

defmodule Noizu.RequestContext.Dispatch do
  def dispatch_rpc(m,f,a,c) do
    Process.put(:nz__context, c)
    apply(m, f, a)
  end
end

defmodule Noizu.RequestContext do
  @moduledoc """
    Noizu.RequestContext
    ==================================================
    Behavior + Dispatcher for tracking request caller + permissions across distributed apps.
    Useful for collating log entries across multiple nodes and services, and maintaining robust security checks across app.
  
    ## Configuration
  
    ## Basic Usage
    
    ### Set and pass Context
    ```
    use Noizu
    def context_from_conn(conn, params) do
      with_context(conn) do
         request_has_permission?(:admin)
         rpc_call(remote, m, f, a, opts)
         rpc_cast(remote, m, f, a, opts)
         context_spawn(remote, fn() -> context_permission?(:admin) end)
         spawn(remote, fn() -> :context_not_applied end)
         MyModule.method_a(:a, :b, :c)
         MyService.forwarded_to_genserver_method(:a, :b, :c)
      end
    end
    ```
    
    ### Obtain Context
    Setting up a method to receive a context arg
    ```
    use Noizu
    
    # with def param - manual setup
    def method_a(arg_1, arg_2, arg_3 \\ [], context \\ inject_context(), options \\ nil)
    def method_a(arg_1, arg_2, arg_3, inject_context(context), options) when context_permission?(context, :admin) do
      method_b(arg_1, arg_2, arg_3, context(), options)
    end
    
  """
  
  defmacro __using__(_ \\ nil) do
    quote do
      require Noizu.RequestContext
      import Noizu.RequestContext
    end
  end
  
  
  #===========================================
  # Records
  #===========================================
  alias Noizu.Types, as: T
  require Record
  
  Record.defrecord(:extended_context,
    token: nil,
    reason: nil,
    auth: nil,
    options: nil,
    user_defined: nil
  )
  
  Record.defrecord(:request_context,
    __status__: :loaded,
    caller: nil,
    requested_on: nil,
    permissions: nil,
    extended: nil
  )
  
  Record.defrecord(:noizu_continuation_monad, value: nil, exception: nil)
  
  #===========================================
  # Types
  #===========================================
  @type request_context :: any
  @type ast() :: term()
  
  #===========================================
  # Behaviour
  #===========================================
  @macrocallback context() :: Macro.t
  @callback escape(reason :: term) :: nil
  
  @macrocallback context_permission?(any) :: any
  @macrocallback context_permission?(any, any) :: any
  @macrocallback context_permission?(any, any, any) :: any
  @macrocallback context_permission?(any, any, any, any) :: any
  @macrocallback or_exit(any) :: any
  
  @macrocallback with_context(any) :: any
  @macrocallback with_context(any, any) :: any
  @macrocallback with_context(any, any, any) :: any
  
  defmacro context() do
    cond do
      Macro.Env.has_var?(__CALLER__, {:nz__context, nil}) ->
        a = quote do
              unquote({:nz__context, [], nil})
            end
        quote do
          unquote(a)
        end
      :else ->
        quote do
          (
            t = Process.get(:nz__context)
            t || Noizu.RequestContext.default_context()
            )
        end
    end
  end
  
  defmacro rpc_call(n, m, f, a, o \\ nil) do
    cond do
      Macro.Env.has_var?(__CALLER__, {:nz__context, nil}) ->
        c = quote do
              unquote({:nz__context, [], nil})
            end
        quote do
          if o = unquote(o) do
            :rpc.call(unquote(n), Noizu.RequestContext.Dispatch, :dispatch_rpc, [unquote(m), unquote(f), unquote(a), unquote(c)], unquote(o))
          else
            :rpc.call(unquote(n), Noizu.RequestContext.Dispatch, :dispatch_rpc, [unquote(m), unquote(f), unquote(a), unquote(c)])
          end
        end
        
        :else -> raise Noizu.ContextException, message: "rpc_call made outside of with_context block", term: {:context, :required}
    end
  end

  defmacro rpc_cast(n, m, f, a) do
    cond do
      Macro.Env.has_var?(__CALLER__, {:nz__context, nil}) ->
        c = quote do
              unquote({:nz__context, [], nil})
            end
        quote do
          :rpc.cast(unquote(n), Noizu.RequestContext.Dispatch, :dispatch_rpc, [unquote(m), unquote(f), unquote(a), unquote(c)])
        end
      :else -> raise Noizu.ContextException, message: "rpc_call made outside of with_context block", term: {:context, :required}
    end
  end
  
  defmacro context_spawn(n, lambda) do
    cond do
      Macro.Env.has_var?(__CALLER__, {:nz__context, nil}) ->
        c = quote do
              unquote({:nz__context, [], nil})
            end
        quote do
          Node.spawn(unquote(n), fn ->
            Process.put(:nz__context, unquote(c))
            unquote(lambda).()
          end)
        end
      :else -> raise Noizu.ContextException, message: "context_spawn made outside of with_context block", term: {:context, :required}
    end
  end
  
  def escape() do
    raise Noizu.ContextException
  end
  def escape(term) do
    raise Noizu.ContextException, term: term
  end

  defmacro context_permission?(permission) do
    quote do
      c = Noizu.RequestContext.context()
      cond do
        Enum.member?(Noizu.RequestContext.request_context(c, :permissions), unquote(permission)) -> :ok
        :else -> raise Noizu.PermissionException, permission: unquote(permission), resource: Noizu.RequestContext.request_context(c, :permissions), term: {:error, {:permission_denied, unquote(permission)}}
      end
    end
  end

  defmacro context_permission?(permission, c) do
    quote do
      cond do
        Enum.member?(Noizu.RequestContext.request_context(unquote(c), :permissions), unquote(permission)) -> :ok
        :else -> raise Noizu.PermissionException, term: {:error, {:permission_denied, unquote(permission)}}
      end
    end
  end
  
  def default_context() do
    request_context(permissions: MapSet.new([:restricted]), requested_on: :os.system_time(:millisecond) )
  end
  
  def from_legacy(v) do
    permissions = Enum.map(v.auth[:permissions] || [], fn({k,v}) -> v && k end)
                  |> Enum.filter(&(&1))
    requested_on = v.time && DateTime.to_unix(v.time, :millisecond) ||  :os.system_time(:millisecond)
    Noizu.RequestContext.request_context(permissions: MapSet.new(permissions), requested_on: requested_on)
  end
  
  defmacro init_context(init)
  defmacro init_context(init = request_context(__status__: :inject)) do
    cond do
      Macro.Env.has_var?(__CALLER__, {:nz__context, nil}) ->
        a = quote do
              unquote({:nz__context, [], nil})
            end
        quote do
          unquote(a)
        end
      :else ->
        quote do
          (
            t = Process.get(:nz__context)
            t || Noizu.RequestContext.default_context()
            )
        end
    end
  end
  defmacro init_context(init = request_context(__status__: :loaded)) do
    init
  end
  defmacro init_context(init) do
    cond do
      Macro.Env.has_var?(__CALLER__, {:nz__context, nil}) ->
        quote do
          case unquote(init) do
            Noizu.RequestContext.request_context(__status__: :inject) -> unquote({:nz__context, [], nil})
            v = %{__struct__: Noizu.ElixirCore.CallingContext} -> Noizu.RequestContext.from_legacy(v)
            v = Noizu.RequestContext.request_context(__status__: _) -> v
          end
        end
      :else ->
        quote do
          case unquote(init) do
            Noizu.RequestContext.request_context(__status__: :inject) ->
              t = Process.get(:nz__context)
              t || Noizu.RequestContext.default_context()
            v = %{__struct__: Noizu.ElixirCore.CallingContext} -> Noizu.RequestContext.from_legacy(v)
            v = Noizu.RequestContext.request_context(__status__: _) -> v
          end
        end
    end
  end

  defmacro set_context(arg1 \\ request_context(__status__: :inject), arg2 \\ nil) do
    {init, inner} = cond do
                      is_tuple(arg1) -> {arg1,arg2}
                      arg1[:as] ->
                        cond do
                          is_nil(arg2) -> {request_context(__status__: :inject), arg1}
                          :else -> {arg2, arg1}
                        end
                      is_struct(arg1) -> {Macro.escape(arg1), arg2}
                      :else -> {arg1,arg2}
                    end
  
    name = inner[:as] || :context
    var = Macro.var(name, nil)
    
    quote do
      var!(unquote(var)) = Noizu.RequestContext.init_context(unquote(init))
      var!(nz__context) = unquote(var)
      # suppress warnings
      _ = unquote({:nz__context, [], nil})
      _ = unquote(var)
    end
  end
  
  defmacro with_context(arg1 \\ request_context(__status__: :inject), arg2 \\ nil, opts) do
    {init, inner} = cond do
                      is_tuple(arg1) -> {arg1,arg2}
                      arg1[:as] ->
                        cond do
                          is_nil(arg2) -> {request_context(__status__: :inject), arg1}
                          :else -> {arg2, arg1}
                        end
                      is_struct(arg1) -> {Macro.escape(arg1), arg2}
                      :else -> {arg1,arg2}
                    end
    
    name = inner[:as] || :context
    var = Macro.var(name, nil)
    do_block = opts[:do] || nil
    else_block = opts[:else] || nil
    if false do
      IO.inspect var, label: :var
      IO.inspect name, label: :as
      IO.inspect do_block, label: :do_block
      IO.inspect else_block, label: :else_block
      IO.inspect init, label: :init
    end
    
    
    case else_block do
      [{:->, _, _}|_] ->
        quote do
          try do
            var!(unquote(var)) = Noizu.RequestContext.init_context(unquote(init))
            var!(nz__context) = unquote(var)
            # suppress warnings
            _ = unquote({:nz__context, [], nil})
            _ = unquote(var)
            unquote(do_block)
          rescue
            unquote(else_block)
          end
        end
      nil ->
        quote do
          try do
            var!(unquote(var)) = Noizu.RequestContext.init_context(unquote(init))
            var!(nz__context) = unquote(var)
            # suppress warnings
            _ = unquote({:nz__context, [], nil})
            _ = unquote(var)
            unquote(do_block)
          rescue
            e in Noizu.ContextException ->
              Noizu.ContextException.to_term(e)
            e in Noizu.PermissionException ->
              Noizu.PermissionException.to_term(e)
          end
        end
      _ ->
        quote do
          try do
            var!(unquote(var)) = Noizu.RequestContext.init_context(unquote(init))
            var!(nz__context) = unquote(var)
            # suppress warnings
            _ = unquote({:nz__context, [], nil})
            _ = unquote(var)
            
            unquote(do_block)
          rescue
            _ in Noizu.ContextException ->
              unquote(else_block)
            _ in Noizu.PermissionException ->
              unquote(else_block)
          end
        end
    end
  
  
  end

end

defmodule Noizu.FooBar do
  use Noizu.RequestContext
  def has_permission?(permission) do
    set_context()
    context_permission?(permission)
    context()
  end
  def has_permission?(permission, context) do
    set_context(context)
    context_permission?(permission)
    context()
  end
  
end
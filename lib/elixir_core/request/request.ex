#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2023 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

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
         context_spawn(remote, fn() -> assert_has_permission?(:admin) end)
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
    def method_a(arg_1, arg_2, arg_3, inject_context(context), options) when assert_has_permission?(context, :admin) do
      method_b(arg_1, arg_2, arg_3, context(), options)
    end
    
  """

  require Noizu.ElixirCore.RequestContext.Types
  
  @doc """
  Generate new Context by passing in Caller, Auth and options.
  """
  def new(caller, auth, manager, time, token, reason, inner_context, options) do
    details = Noizu.ElixirCore.RequestContext.Types.extended_request_context(
      time: time,
      token: token,
      reason: reason,
      options: options
    )
    context = Noizu.ElixirCore.RequestContext.Types.request_context(
      caller: caller,
      auth: auth,
      manager: manager,
      extended: details,
      inner_context: inner_context
    )
    {:ok, context}
  end
  def new(caller, options) do
    with {:ok, auth} <- Noizu.ElixirCore.RequestContext.Manager.Behaviour.auth(caller, options) do
      manager = Noizu.ElixirCore.RequestContext.Manager.Behaviour.provider()
      time = options[:current_time] || DateTime.utc_now()
      token = Noizu.ElixirCore.RequestContext.Manager.Behaviour.generate_token(nil, options)
      reason = Noizu.ElixirCore.RequestContext.Manager.Behaviour.generate_reason(nil, options)
      details = Noizu.ElixirCore.RequestContext.Types.extended_request_context(
        time: time,
        token: token,
        reason: reason,
        options: options[:request_context]
      )
      context = Noizu.ElixirCore.RequestContext.Types.request_context(
        caller: caller,
        auth: auth,
        manager: manager,
        extended: details,
        inner_context: nil
      )
      {:ok, context}
    end
  end

  
  def new_source(source, caller, options) do
    with {:ok, auth} <- Noizu.ElixirCore.RequestContext.Manager.Behaviour.auth(caller, options) do
      context_options = options[:request_context]
      manager = Noizu.ElixirCore.RequestContext.Manager.Behaviour.provider()
      time = options[:current_time] || DateTime.utc_now()
      token = Noizu.ElixirCore.RequestContext.Manager.Behaviour.token(source, options)
      reason = Noizu.ElixirCore.RequestContext.Manager.Behaviour.request_reason(source, options)
      details = Noizu.ElixirCore.RequestContext.Types.extended_request_context(
        time: time,
        token: token,
        reason: reason,
        options: context_options
      )
      context = Noizu.ElixirCore.RequestContext.Types.request_context(
        caller: caller,
        auth: auth,
        manager: manager,
        extended: details,
        inner_context: nil
      )

      # possible this should reference the inner options[:request_context] options dict.
      if options[:logger_init] != false, do: meta_update(context)
      {:ok, context}
    end
  end
  
  
  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  
  #
  #  @vsn 1.0
  #  @type t :: %CallingContext{
  #               caller: tuple,
  #               token: String.t,
  #               reason: String.t,
  #               auth: Any,
  #               options: Map.t,
  #               time: DateTime.t | nil,
  #               outer_context: CalingContext.t,
  #               vsn: float
  #             }
  #
  
  def to_legacy(Noizu.ElixirCore.RequestContext.Types.request_context() = context, options) do
    Noizu.ElixirCore.RequestContext.Types.request_context(
      caller: caller,
      auth: auth,
      extended: details,
      inner_context: inner_context
    ) = context
    
    # Auth
    Noizu.ElixirCore.RequestContext.Types.request_authorization(
      roles: roles,
      permissions: permissions
    ) = auth
    roles = MapSet.to_list(roles || [])
            |> Enum.map(&({&1, true}))
            |> Map.new()
    permissions = Map.merge(permissions || %{}, roles)
    auth = %{permissions: permissions, roles: roles}
    
    # Details
    Noizu.ElixirCore.RequestContext.Types.extended_request_context(
      time: time,
      token: token,
      reason: reason,
      options: context_options
    ) = details
    
    # Nesting
    outer_context = (with {:ok, oc} <- inner_context && to_legacy(inner_context, options) do
                       oc
                     else
                       _ -> nil
                     end)
    
    context = %Noizu.ElixirCore.CallingContext{
      caller: caller,
      token: token,
      reason: reason,
      auth: auth,
      options: context_options,
      time: time,
      outer_context: outer_context,
    }
    {:ok, context}
  end
  
  def from_legacy(%Noizu.ElixirCore.CallingContext{} = context, options) do
    manager = Noizu.ElixirCore.RequestContext.Manager.Behaviour.provider()
    details = Noizu.ElixirCore.RequestContext.Types.extended_request_context(
      time: context.time,
      token: context.token,
      reason: context.reason,
      options: context.options
    )

    # There is a bit of a mismatch with upstream ACL libraries and then new pattern here we will want to iron out.
    roles = Enum.map(context.auth[:permissions] || [],
              fn
                ({k,true}) -> k
                ({_,_}) -> nil
              end) |> Enum.filter(&(&1)) |> MapSet.new()
    auth = Noizu.ElixirCore.RequestContext.Types.request_authorization(
      roles: roles,
      permissions: %{}
    )

    inner_context = (with {:ok, inner} <- (context.outer_context && from_legacy(context.outer_context, options)) do
                       inner
                     else
                       _ -> nil
                     end)

    context = Noizu.ElixirCore.RequestContext.Types.request_context(
      caller: context.caller,
      auth: auth,
      manager: manager,
      extended: details,
      inner_context: inner_context
    )
    {:ok, context}
  end
  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def default(type, nil, options) when type in [:admin, :restricted, :internal, :system] do
    with {:ok, caller} <- Noizu.ElixirCore.RequestContext.Manager.Behaviour.caller(type, options) do
      new(caller, options)
    end
  end
  def default(type, %Noizu.ElixirCore.CallingContext{} = escalate, options) do
    with {:ok, escalate} <- from_legacy(escalate, options),
         {:ok, caller} <- Noizu.ElixirCore.RequestContext.Manager.Behaviour.caller(type, options),
         {:ok, auth} <- Noizu.ElixirCore.RequestContext.Manager.Behaviour.auth(caller, options) do
      context = Noizu.ElixirCore.RequestContext.Types.request_context(
        escalate,
        caller: caller,
        auth: auth,
        inner_context: escalate
      )
      {:ok, context}
    end
  end
  def default(type, Noizu.ElixirCore.RequestContext.Types.request_context() = escalate, options) do
    with {:ok, caller} <- Noizu.ElixirCore.RequestContext.Manager.Behaviour.caller(type, options),
         {:ok, auth} <- Noizu.ElixirCore.RequestContext.Manager.Behaviour.auth(caller, options) do
      context = Noizu.ElixirCore.RequestContext.Types.request_context(
        escalate,
        caller: caller,
        auth: auth,
        inner_context: escalate
      )
      {:ok, context}
    end
  end
  def default(type, %{__struct__: Plug.Conn} = conn, options) when type in [:admin, :restricted, :internal, :system] do
    with {:ok, caller} <- Noizu.ElixirCore.RequestContext.Manager.Behaviour.caller(type, options) do
      new_source(conn, caller, options)
    end
  end
  
  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def system(), do: default(:system, nil, nil)
  def system(source), do: default(:system, source, nil)
  def system(source, options), do: default(:system, source, options)

  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def internal(), do: default(:internal, nil, nil)
  def internal(source), do: default(:internal, source, nil)
  def internal(source, options), do: default(:internal, source, options)

  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def restricted(), do: default(:restricted, nil, nil)
  def restricted(source), do: default(:restricted, source, nil)
  def restricted(source, options), do: default(:restricted, source, options)
  
  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  @doc """
    Create new calling context with default admin user caller and permissions.
  """
  def admin(), do: default(:admin, nil, nil)
  def admin(source), do: default(:admin, source, nil)
  def admin(source, options), do: default(:admin, source, options)



  @doc """
  Extract CallingContext meta data for Logger
  """
  def metadata(Noizu.ElixirCore.RequestContext.Types.request_context() = context) do
    Noizu.ElixirCore.RequestContext.Types.request_context(caller: caller, extended: extended) = context
    Noizu.ElixirCore.RequestContext.Types.extended_request_context(options: options, token: token, time: time) = extended
    filter = case options[:log_filter] do
                v when is_list(v) -> v
                _ -> []
             end
    [context_token: token, context_time: time, context_caller: caller] ++ filter
  end
  def metadata(_) do
    [context_token: :none, context_time: 0, context_caller: :none]
  end

  @doc """
  Strip CallingContext meta data from Logger.
  """
  def meta_strip(context) do
    Keyword.keys(metadata(context))
    |> Enum.map(&({&1, nil}))
    |> Logger.metadata()
  end

  @doc """
  Update Logger with CallingContext meta data.
  """
  def meta_update(context) do
    (Logger.metadata() || [])
    |> Keyword.merge(metadata(context))
    |> Logger.metadata()
  end


end
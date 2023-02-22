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

  def new_source(source, caller,  options) do
    with {:ok, auth} <- Noizu.ElixirCore.RequestContext.Manager.Behaviour.auth(caller, options) do
      manager = Noizu.ElixirCore.RequestContext.Manager.Behaviour.provider()
      time = options[:current_time] || DateTime.utc_now()
      token = Noizu.ElixirCore.RequestContext.Manager.Behaviour.token(source, options)
      reason = Noizu.ElixirCore.RequestContext.Manager.Behaviour.request_reason(source, options)
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


  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  def default(type, nil, options) when type in [:admin, :restricted, :internal, :system] do
    with {:ok, caller} <- Noizu.ElixirCore.RequestContext.Manager.Behaviour.caller(type, options) do
      new(caller, options)
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
#  def admin(
#        Noizu.ElixirCore.RequestContext.Types.request_context(
#          caller: caller,
#          auth: auth,
#          manager: manager,
#          extended: extended,
#        ) = context) do
#    options = nil
#    caller = caller || Noizu.ElixirCore.RequestContext.Manager.Behaviour.caller(:admin, options)
#    auth = Noizu.ElixirCore.RequestContext.Manager.Behaviour.auth(caller, options)
#    {:ok,
#      Noizu.ElixirCore.RequestContext.Types.request_context(context,
#        caller: caller,
#        auth: auth,
#        inner_context: context
#      )
#    }
#  end



end
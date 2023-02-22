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
      options: options,
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

  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  @doc """
    Create new calling context with default admin user caller and permissions.
  """
  def admin() do
    options = nil
    with {:ok, caller} <- Noizu.ElixirCore.RequestContext.Manager.Behaviour.caller(:admin, options),
         {:ok, auth} <- Noizu.ElixirCore.RequestContext.Manager.Behaviour.auth(caller, options) do
      manager = Noizu.ElixirCore.RequestContext.Manager.Behaviour.provider()
      time = DateTime.utc_now()
      token = Noizu.ElixirCore.RequestContext.Manager.Behaviour.generate_token(nil, options)
      reason = Noizu.ElixirCore.RequestContext.Manager.Behaviour.generate_reason(nil, options)
      new(caller, auth, manager, time, token, reason, nil, [])
    end
  end
  
  def admin(%{__struct__: Plug.Conn} = conn), do: admin(conn, nil)
  def admin(_), do: admin()
  
  def admin(%{__struct__: Plug.Conn} = conn, options) do
    with {:ok, caller} <- Noizu.ElixirCore.RequestContext.Manager.Behaviour.caller(:admin, options),
         {:ok, auth} <- Noizu.ElixirCore.RequestContext.Manager.Behaviour.auth(caller, options) do
      manager = Noizu.ElixirCore.RequestContext.Manager.Behaviour.provider()
      time = options[:current_time] || DateTime.utc_now()
      token = Noizu.ElixirCore.RequestContext.Manager.Behaviour.token(conn, options)
      reason = Noizu.ElixirCore.RequestContext.Manager.Behaviour.request_reason(conn, options)
      new(caller, auth, manager, time, token, reason, nil, options[:context_options])
    end
  end
  def admin(_,_), do: admin()
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
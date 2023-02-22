#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2023 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.RequestContext.Manager.Behaviour do
  alias Noizu.Types, as: T
  alias Noizu.ERP.Types, as: T_ERP

  @doc """
    Setup unauthenticated user handle from incoming Conn Plug. Possibly based on device id, ip address, persistent cookie identifier, etc.
  """
  @callback unauthenticated(source :: any, options :: any) :: T_ERP.ref
  @callback generate_token(source :: any, options :: any) :: any
  @callback token(source :: any, options :: any) :: any
  @callback generate_reason(source :: any, options :: any) :: any
  @callback request_reason(source :: any, options :: any) :: any

  @doc """
    Returns caller of specified type (:admin, :system, :restricted, etc.)
  """
  @callback caller(source :: any, options :: any) :: T_ERP.ref

  @doc """
    Returns Auth struct containing user' roles, permissions, and caller specific meta data needed to check per resource specific permissions for specified user
  """
  @callback auth(source :: any, options :: any) :: term

  
  #==================================================
  #
  #==================================================
  def provider() do
    Application.get_env(:noizu_core, :request_context, Noizu.ElixirCore.RequestContext.Manager.Default)
  end

  #==================================================
  # Dispatch
  #==================================================
  def unauthenticated(source, options) do
    apply(provider(), :unauthenticated, [source, options])
  end
  def generate_token(source, options) do
    apply(provider(), :generate_token, [source, options])
  end
  def token(source, options) do
    apply(provider(), :token, [source, options])
  end
  def generate_reason(source, options) do
    apply(provider(), :generate_reason, [source, options])
  end
  def request_reason(source, options) do
    apply(provider(), :request_reason, [source, options])
  end
  def caller(source, options) do
    apply(provider(), :caller, [source, options])
  end
  def auth(source, options) do
    apply(provider(), :auth, [source, options])
  end

  defmacro __using__(options \\ nil) do
    quote do
      alias Noizu.ElixirCore.RequestContext.Manager.Default, as: Provider
      
      def unauthenticated(source, options), do: Provider.unauthenticated(source, options)
      def generate_token(source, options), do: Provider.generate_token(source, options)
      def token(source, options), do: Provider.token(source, options)
      def request_reason(source, options), do: Provider.token(source, options)
      def generate_reason(source, options), do: Provider.generate_reason(source, options)
      def caller(source, options), do: Provider.caller(source, options)
      def auth(source, options), do: Provider.unauthenticated(source, options)
      
      defoverridable [
        unauthenticated: 2,
        generate_token: 2,
        token: 2,
        generate_reason: 2,
        request_reason: 2,
        caller: 2,
        auth: 2,
      ]
      
    end
  end
  
end
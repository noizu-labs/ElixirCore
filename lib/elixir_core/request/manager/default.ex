#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2023 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.RequestContext.Manager.Default do
  #alias Noizu.Types, as: T
  require Noizu.ERP.Types
  require  Noizu.ElixirCore.RequestContext.Types
  
  #-------------------------------------
  #
  #-------------------------------------
  def unauthenticated(source, _options) do
    {:ok, {:ref, Noizu.ElixirCore.UnauthenticatedCallerEntity, get_ip(source)}}
  end
  
  #-------------------------------------
  #
  #-------------------------------------
  def caller(source, _options) when source in [:unauthenticated, :restricted, :internal, :system, :admin], do: Noizu.ElixirCore.CallerEntity.ref_ok(source)
  
  #-------------------------------------
  #
  #-------------------------------------
  def generate_token(_, options) do
    unless options[:generate] == false do
      apply(UUID, :uuid4, [:hex])
    end
  end
  
  #-------------------------------------
  #
  #-------------------------------------
  def token(nil = source, options) do
    Noizu.ElixirCore.RequestContext.Manager.Behaviour.generate_token(source, options)
  end
  
  def token(%{__struct__: Plug.Conn} = conn, options) do
    cond do
      token = conn.body_params["request-id"] -> token
      :else ->
        with [token|_] <- apply(Plug.Conn, :get_resp_header, [conn, "x-request-id"]) do
          token
        else
          _ -> Noizu.ElixirCore.RequestContext.Manager.Behaviour.generate_token(conn, options)
        end
    end
  end
  
  
  #-------------------------------------
  #
  #-------------------------------------
  def generate_reason(_, options) do
    unless options[:generate] == false do
      "Not Provided"
    end
  end
  
  #-------------------------------------
  #
  #-------------------------------------
  def request_reason(%{__struct__: Plug.Conn} = conn, options) do
    cond do
      reason = conn.body_params["call-reason"] -> reason
      :else ->
        with [reason|_] <- apply(Plug.Conn, :get_resp_header, [conn, "x-call-reason"]) do
          reason
        else
          _ -> Noizu.ElixirCore.RequestContext.Manager.Behaviour.generate_reason(conn, options)
        end
    end
  end
  
  #-------------------------------------
  #
  #-------------------------------------
  def auth({:ref, Noizu.ElixirCore.UnauthenticatedCallerEntity, _}, _) do
    {:ok, Noizu.ElixirCore.RequestContext.Types.request_authorization(roles: MapSet.new([:unauthenticated, :restricted]), permissions: %{})}
  end
  def auth({:ref, Noizu.ElixirCore.CallerEntity, :unauthenticated}, _) do
    {:ok,    Noizu.ElixirCore.RequestContext.Types.request_authorization(roles: MapSet.new([:unauthenticated, :restricted]), permissions: %{})}
  end
  def auth({:ref, Noizu.ElixirCore.CallerEntity, :restricted}, _) do
    {:ok,      Noizu.ElixirCore.RequestContext.Types.request_authorization(roles: MapSet.new([:restricted]), permissions: %{})}
  end
  def auth({:ref, Noizu.ElixirCore.CallerEntity, :internal}, _) do
    {:ok, Noizu.ElixirCore.RequestContext.Types.request_authorization(roles: MapSet.new([:internal]), permissions: %{})}
  end
  def auth({:ref, Noizu.ElixirCore.CallerEntity, :system}, _) do
    {:ok,      Noizu.ElixirCore.RequestContext.Types.request_authorization(roles: MapSet.new([:system, :internal]), permissions: %{})}
  end
  def auth({:ref, Noizu.ElixirCore.CallerEntity, :admin}, _) do
    {:ok,      Noizu.ElixirCore.RequestContext.Types.request_authorization(roles: MapSet.new([:admin, :system, :internal]), permissions: %{})}
  end
  def auth(_, _) do
    {:ok,     Noizu.ElixirCore.RequestContext.Types.request_authorization(roles: MapSet.new([:unauthenticated, :restricted]), permissions: %{})}
  end
  
  #=============================================================
  # Helpers
  #=============================================================
  
  #-------------------------------------
  #
  #-------------------------------------
  def get_ip(conn) do
    case apply(Plug.Conn, :get_req_header, [conn, "x-forwarded-for"]) do
      [h|_] -> h
      [] -> conn.remote_ip |> Tuple.to_list |> Enum.join(".")
      nil ->  conn.remote_ip |> Tuple.to_list |> Enum.join(".")
    end
  end
end
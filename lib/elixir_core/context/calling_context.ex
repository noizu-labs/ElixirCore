#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2017 Noizu Labs, Inc.. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.CallingContext do
  alias Noizu.ElixirCore.CallingContext
  require Logger
  @vsn 1.0

  @type t :: %CallingContext{
    caller: tuple,
    token: String.t,
    reason: String.t,
    auth: Any,
    options: Map.t,
    time: DateTime.t | nil,
    outer_context: CalingContext.t,
    vsn: float
  }

  defstruct [
    caller: nil,
    token: nil,
    reason: nil,
    auth: nil,
    options: nil,
    time: nil,
    outer_context: nil,
    vsn: @vsn
  ]

  defp empty_reason() do
    Application.get_env(:noizu_core, :default_request_reason, :none)
  end

  defp default_token(conn, default) do
    case Application.get_env(:noizu_core, :token_strategy, {__MODULE__, :extract_token}) do
      {m, f} -> apply(m,f, [conn, default])
      v when is_function(v) -> v.(conn, default)
      _ -> extract_token(conn, default)
    end
  end

  defp default_reason(conn, default) do
    case Application.get_env(:noizu_core, :token_strategy, {__MODULE__, :extract_reason}) do
      {m, f} -> apply(m,f, [conn, default])
      v when is_function(v) -> v.(conn, default)
      _ -> extract_reason(conn, default)
    end
  end

  defp default_restricted_user() do
    Application.get_env(:noizu_core, :default_internal_user, {:ref, Noizu.ElixirCore.CallerEntity, :restricted})
  end

  defp default_internal_user() do
    Application.get_env(:noizu_core, :default_internal_user, {:ref, Noizu.ElixirCore.CallerEntity, :internal})
  end

  defp default_system_user() do
    Application.get_env(:noizu_core, :default_system_user, {:ref, Noizu.ElixirCore.CallerEntity, :system})
  end

  defp default_admin_user() do
    Application.get_env(:noizu_core, :default_admin_user, {:ref, Noizu.ElixirCore.CallerEntity, :admin})
  end

  defp default_restricted_auth() do
    Application.get_env(:noizu_core, :default_internal_auth, %{permissions: %{restricted: true}})
  end

  defp default_internal_auth() do
    Application.get_env(:noizu_core, :default_internal_auth, %{permissions: %{internal: true}})
  end

  defp default_system_auth() do
    Application.get_env(:noizu_core, :default_system_auth, %{permissions: %{system: true, internal: true}})
  end

  defp default_admin_auth() do
    Application.get_env(:noizu_core, :default_admin_auth, %{permissions: %{admin: true, system: true, internal: true}})
  end

  defp get_ip(conn) do
    case Plug.Conn.get_req_header(conn, "x-forwarded-for") do
      [h|_] -> h
      [] -> conn.remote_ip |> Tuple.to_list |> Enum.join(".")
      nil ->  conn.remote_ip |> Tuple.to_list |> Enum.join(".")
    end
  end # end get_ip/1

  def extract_token(nil, default) do
    if default == :generate do
      UUID.uuid4(:hex)
    else
      default
    end
  end

  def extract_token(conn, default) do
    conn.body_params["request-id"] || case (Plug.Conn.get_resp_header(conn, "x-request-id")) do
      [] ->
        if default == :generate do
          UUID.uuid4(:hex)
        else
          default
        end
      [h|_t] -> h
    end
  end # end extract_token/0

  def extract_reason(conn, default) do
    conn.body_params["call-reason"] || case (Plug.Conn.get_resp_header(conn, "x-call-reason")) do
      [] -> default || empty_reason()
      [h|_t] -> h
    end
  end

  def extract_caller(%Plug.Conn{} = conn, default) do
    case default do
      :restricted -> default_restricted_user()
      :internal -> default_restricted_user()
      :system -> default_restricted_user()
      :user -> default_restricted_user()
      :unauthenticated -> {:ref, Noizu.ElixirCore.UnauthenticatedCallerEntity, get_ip(conn)}
      _ -> {:ref, Noizu.ElixirCore.UnauthenticatedCallerEntity, get_ip(conn)}
    end
  end

  defp default_auth(caller, _auth) do
    case caller do
      {:ref, Noizu.ElixirCore.CallerEntity, :restricted} -> default_restricted_auth()
      {:ref, Noizu.ElixirCore.CallerEntity, :internal} -> default_internal_auth()
      {:ref, Noizu.ElixirCore.CallerEntity, :system} -> default_system_auth()
      {:ref, Noizu.ElixirCore.CallerEntity, :admin} -> default_admin_auth()
      {:ref, Noizu.ElixirCore.UnauthenticatedCallerEntity, _ip} -> %{permissions: %{unauthenticated: true}}
    end
  end


  def get_token(conn, default \\ :generate) do
    default_token(conn, default)
  end

  def get_reason(conn, default \\ nil) do
    default_reason(conn, default)
  end

  def get_caller(%Plug.Conn{} = conn, default \\ :unauthenticated) do
    case Application.get_env(:noizu_core, :get_plug_caller, {__MODULE__, :extract_caller}) do
      v when is_function(v) -> v.(conn, default)
      {m, f} -> apply(m, f, [conn, default])
      _ -> extract_caller(conn, default)
    end
  end

  def get_auth(caller, options) do
    case Application.get_env(:noizu_core, :acl_strategy, {__MODULE__, :default_auth}) do
      v when is_function(v) -> v.(caller, options)
      {m, f} -> apply(m, f, [caller, options])
      _ -> default_auth(caller, options)
    end
  end

  #-----------------------------------------------------------------------------
  # Helper CallingContext
  #-----------------------------------------------------------------------------
  def new_conn(caller, auth, %Plug.Conn{} = conn, options \\ %{logger_init: true}) do
    reason = get_reason(conn, options[:default][:reason])
    token = get_token(conn, options[:default][:token] || :generate)
    time = options[:time] || DateTime.utc_now()
    outer_context = options[:outer_context]
    context = %__MODULE__{caller: caller, auth: auth, time: time, outer_context: outer_context, token: token, reason: reason}
    if Map.get(options, :logger_init, true) do
      meta_update(context)
    end
    context
  end

  def new_conn(%Plug.Conn{} = conn, options \\ %{logger_init: true}) do
    caller = get_caller(conn, options)
    auth = get_auth(caller, options)
    reason = get_reason(conn, options[:default][:reason])
    token = get_token(conn, options[:default][:token] || :generate)
    time = options[:time] || DateTime.utc_now()
    outer_context = options[:outer_context]
    context = %__MODULE__{caller: caller, auth: auth, time: time, outer_context: outer_context, token: token, reason: reason}
    if Map.get(options, :logger_init, true) do
      meta_update(context)
    end
    context
  end

  def new(caller, auth, %{} = options) do
    time = options[:time] || DateTime.utc_now()
    token = options[:token] && options[:token] != :generate && options[:token] || default_token(nil, :generate)
    reason = options[:reason] || empty_reason()
    outer_context = options[:outer_context]
    %__MODULE__{caller: caller, auth: auth, time: time, outer_context: outer_context, token: token, reason: reason}
  end

  #-----------------------------------------------------------------------------
  # Internal CallingContext
  #-----------------------------------------------------------------------------
  def internal(), do: new(default_internal_user(), default_internal_auth(), %{})
  def internal(%__MODULE__{} = this), do: %__MODULE__{this| auth: default_internal_auth(), outer_context: this}
  def internal(options), do: new(default_internal_user(), default_internal_auth(), options)
  def internal(%Plug.Conn{} = conn, options), do: new_conn(default_internal_user(), default_internal_auth(), conn, options)

  #-----------------------------------------------------------------------------
  # System CallingContext
  #-----------------------------------------------------------------------------
  def system(), do: new(default_system_user(), default_system_auth(), %{})
  def system(%__MODULE__{} = this), do: %__MODULE__{this| auth: default_system_auth(), outer_context: this}
  def system(options), do: new(default_system_user(), default_system_auth(), options)
  def system(%Plug.Conn{} = conn, options), do: new_conn(default_system_user(), default_system_auth(), conn, options)

  #-----------------------------------------------------------------------------
  # Restricted CallingContext
  #-----------------------------------------------------------------------------
  def restricted(), do: new(default_restricted_user(), default_restricted_auth(), %{})
  def restricted(%__MODULE__{} = this), do: %__MODULE__{this| auth: default_restricted_auth(), outer_context: this}
  def restricted(options), do: new(default_restricted_user(), default_restricted_auth(), options)
  def restricted(%Plug.Conn{} = conn, options), do: new_conn(default_restricted_user(), default_restricted_auth(), conn, options)

  #-----------------------------------------------------------------------------
  # Admin CallingContext
  #-----------------------------------------------------------------------------
  def admin(), do: new(default_admin_user(), default_admin_auth(), %{})
  def admin(%__MODULE__{} = this), do: %__MODULE__{this| auth: default_admin_auth(), outer_context: this}
  def admin(options), do: new(default_admin_user(), default_admin_auth(), options)
  def admin(%Plug.Conn{} = conn, options), do: new_conn(default_admin_user(), default_admin_auth(), conn, options)

  def metadata(nil) do
    [context_token: :none, context_time: 0, context_caller: :none]
  end

  def metadata(context) do
    [context_token: context.token, context_time: context.time, context_caller: context.caller]
  end

  def meta_update(context) do
    (Logger.metadata() || [])
    |> Keyword.merge(metadata(context))
    |> Logger.metadata()
  end
end # end defmodule Noizu.Scaffolding.CallingContext


if Application.get_env(:noizu_scaffolding, :inspect_calling_context, true) do
  #-----------------------------------------------------------------------------
  # Inspect Protocol
  #-----------------------------------------------------------------------------
  defimpl Inspect, for: Noizu.ElixirCore.CallingContext do
    import Inspect.Algebra
    def inspect(entity, opts) do
      heading = "#CallingContext(#{entity.token})"
      {seperator, end_seperator} = if opts.pretty, do: {"\n   ", "\n"}, else: {" ", " "}
      inner = cond do
        opts.limit == :infinity ->
          concat(["<#{seperator}", to_doc(Map.from_struct(entity), opts), "#{seperator}>"])
        opts.limit >= 200 ->
          concat ["<",
          "#{seperator}caller: #{inspect entity.caller},",
          "#{seperator}reason: #{inspect entity.reason},",
          "#{seperator}permissions: #{inspect entity.auth[:permissions]}",
          "#{end_seperator}>"]
        opts.limit >= 150 ->
          concat ["<",
          "#{seperator}caller: #{inspect entity.caller},",
          "#{seperator}reason: #{inspect entity.reason}",
          "#{end_seperator}>"]
        opts.limit >= 100 ->
          concat ["<",
          "#{seperator}caller: #{inspect entity.caller}",
          "#{end_seperator}>"]
        true -> "<>"
      end
      concat [heading, inner]
    end # end inspect/2
  end # end defimpl
end

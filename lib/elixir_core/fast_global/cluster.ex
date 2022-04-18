#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.FastGlobal.Cluster do
  @vsn 1.0
  alias Noizu.FastGlobal.Record

  def get_settings() do
    get(:fast_global_settings,
      fn() ->
        try do
          if :ok == Noizu.FastGlobal.Database.Settings.wait(100) do
            case Noizu.FastGlobal.Database.Settings.read!(:fast_global_settings) do
              %Noizu.FastGlobal.Database.Settings{value: v} -> v
              _ -> {:fast_global, :no_cache, %{}}
            end
          else
            {:fast_global, :no_cache, %{}}
          end
        rescue _e -> {:fast_global, :no_cache, %{}}
        catch _e -> {:fast_global, :no_cache, %{}}
        end
      end
    )
  end

  #-------------------
  # sync_record
  #-------------------
  def sync_record(identifier, default, options) do
    value = if is_function(default, 0) do
      default.()
    else
      default
    end

    if Semaphore.acquire({:fg_write_record, identifier}, 1) do
      spawn fn ->
        try do
          settings = cond do
            identifier == :fast_global_settings -> %{}
            true -> get_settings()
          end
          origin = options[:origin] || settings[:origin]
          record = try do
            origin && :rpc.call(origin, __MODULE__, :get_record, [identifier], 15_000)
          rescue _e -> nil
          catch _e -> nil
          end

          case record do
            %Record{} ->
              put(identifier, record)
            _ ->
              case value do
                {:fast_global, :no_cache, _} -> :bypass
                _ ->
                  pool = ((options[:pool] || Node.list() ++ [node()])) |> Enum.uniq()
                  update = %Record{identifier: identifier, origin: origin || node(), pool: pool, value: value, revision: 1, ts: :os.system_time(:millisecond)}
                  Enum.map(update.pool, &(&1 == node() && FastGlobal.put(identifier, update) ||  :rpc.cast(&1, FastGlobal, :put, [identifier, update])))
                  :ok
              end
          end
        rescue _e -> nil
        catch _e -> nil
        end
        Semaphore.release({:fg_write_record, identifier})
      end
    end

    case value do
      {:fast_global, :no_cache, v} -> v
      _ ->
        value
    end
  end

  #-------------------
  # get
  #-------------------
  def get(identifier), do: get(identifier, nil, %{})
  def get(identifier, default), do: get(identifier, default, %{})
  def get(identifier, default, options) do
    case FastGlobal.get(identifier, :no_match) do
      %Record{value: v} -> v
      :no_match -> sync_record(identifier, default, options)
      error -> error
    end
  end

  #-------------------
  # get_record/1
  #-------------------
  def get_record(identifier), do: FastGlobal.get(identifier)

  #-------------------
  # put/3
  #-------------------
  def put(identifier, value, options \\ %{})
  def put(identifier, %Record{} = record, _options) do
    FastGlobal.put(identifier, record)
  end
  def put(identifier, value, options) do
    settings = get_settings()
    origin = options[:origin] || settings[:origin] || node()
    cond do
      origin == node() -> coordinate_put(identifier, value, settings, options)
      origin == nil -> :error
      true -> :rpc.cast(origin, Noizu.FastGlobal.Cluster, :coordinate_put, [identifier, value, settings, options])
    end
  end

  #-------------------
  # coordinate_put
  #-------------------
  def coordinate_put(identifier, value, settings, options) do
    update = case get_record(identifier) do
      %Record{} = record ->
        pool = options[:pool] || settings[:pool] || Node.list()
        pool = ([node()] ++ pool) |> Enum.uniq()
        %Record{record| origin: node(), pool: pool, value: value, revision: record.revision + 1, ts: :os.system_time(:millisecond)}
      nil ->
        pool = options[:pool] || settings[:pool] || Node.list()
        pool = ([node()] ++ pool) |> Enum.uniq()
        %Record{identifier: identifier, origin: node(), pool: pool, value: value, revision: 1, ts: :os.system_time(:millisecond)}
    end

    # @TODO we actually need to wait until recieved, this will fail immedietly if semaphore not acquired.
    Semaphore.call({:fg_update_record, identifier}, 1,
      fn() ->
        Enum.map(update.pool,
          fn(n) ->
            if n == node() do
              put(identifier, update, options)
            else
              :rpc.cast(n, Noizu.FastGlobal.Cluster, :put, [identifier, update, options])
            end
          end)
      end)
    :ok
  end
end

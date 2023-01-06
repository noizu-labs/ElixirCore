#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.FastGlobal.Cluster do
  @vsn 1.0
  alias Noizu.FastGlobal.Record
  require Logger

  def get_settings() do
    get(:fast_global_settings,
      fn() ->
        try do
          with :ok <- Noizu.FastGlobal.Database.Settings.wait(100) do
            case Noizu.FastGlobal.Database.Settings.read!(:fast_global_settings) do
              %Noizu.FastGlobal.Database.Settings{value: v} -> v
              _ ->
                Logger.warn("""
                [Noizu.FastGlobal.Cluster]: setting value not set or readable. Try
                ```Elixir
                 %Noizu.FastGlobal.Database.Settings{identifier: :fast_global_settings, value: %{}}
                 |> Noizu.FastGlobal.Database.Settings.write!()
                ```
                """)
                {:fast_global, :no_cache, %{}}
            end
          else
            error ->
              Logger.warn("[Noizu.FastGlobal.Cluster]: Not Loaded #{inspect error}")
              {:fast_global, :no_cache, %{}}
          end
        rescue _e -> {:fast_global, :no_cache, %{}}
        catch _e -> {:fast_global, :no_cache, %{}}
        end
      end
    )
  end

  #-------------------
  # sync_record__write
  #-------------------
  def sync_record__write(identifier, value, options, _tsup) do
    Logger.warn("[Noizu.FastGlobal.Cluster] Write: #{identifier}")
    settings = cond do
                 identifier == :fast_global_settings -> %{}
                 :else -> get_settings()
               end
    origin = options[:origin] || settings[:origin]
    try do
      cond do
        origin == node() -> get_record(identifier)
        :else ->
          timeout = options[:timeout][:get_record] || 5_000
          :rpc.call(origin, __MODULE__, :get_record, [identifier], timeout )
      end
    rescue _e -> nil
    catch _e -> nil
    end
    |> case do
         record = %Record{} -> put(identifier, record)
         _ ->
           pool = [node() | (options[:pool] || Node.list())]
                  |> Enum.uniq()
           record = %Record{
             identifier: identifier,
             origin: origin || node(),
             pool: pool,
             value: value,
             revision: 1,
             ts: :os.system_time(:millisecond)
           }
           [local|remote] = Enum.map(record.pool,
             fn (target) ->
               cond do
                 target == node() ->
                   Task.async(fn -> put(identifier, record) end)
                 :else ->
                   Task.async(fn ->
                     cond do
                       options[:fg][:local_only] -> :skip
                       options[:fg][:sync] -> :rpc.call(target, Noizu.FastGlobal.Cluster, :put, [identifier, record], :infinity)
                       :else -> :rpc.cast(target, Noizu.FastGlobal.Cluster, :put, [identifier, record])
                     end
                   end)
               end
             end
           )
      
           timeout = options[:timeout][:put_record] || 15_000
           shutdown_after = cond do
                              v = options[:timeout][:wait_record] -> v
                              is_integer(timeout) -> timeout * 2
                              :else -> timeout
                            end
      
           [local|remote]
           |> Task.yield_many(timeout)
           |> Enum.map(
                fn({task, res}) ->
                  cond do
                    res -> {task, res}
                    task == local -> {task, Task.await(task, :infinity)}
                    :else ->
                      # {task, Task.shutdown(task, shutdown_after)}
                      :ignore
                  end
                end)
       end
  rescue _e -> nil
  catch _e -> nil
  end

  def sync_record(identifier, default, options, tsup \\ nil) do
    if Semaphore.acquire({:fg_write_record, identifier}, 1) do
      cond do
        is_function(default, 1) -> default.(:has_lock)
        is_function(default, 0) -> default.()
        :else -> default
      end
      |> case do
           {:fast_global, :no_cache, value} ->
             # todo deal with back pressure to avoid hitting ets to hard here.
             Semaphore.release({:fg_write_record, identifier})
             value
           value ->
             cond do
               tsup == false ->
                 spawn fn ->
                   try do
                     sync_record__write(identifier, value, options, tsup)
                   rescue _ -> :swallow
                   catch :exit, _ -> :swallow
                     _ -> :swallow
                   end
                   Semaphore.release({:fg_write_record, identifier})
                 end
               :else ->
                 tsup = tsup || Noizu.FastGlobal.Cluster
                 Task.Supervisor.async_nolink(tsup,
                   fn ->
                     task = Task.Supervisor.async_nolink(tsup,
                       fn ->
                         sync_record__write(identifier, value, options, tsup)
                       end
                     )
                     timeout = options[:timeout][:fg] || 60_000
                     shutdown = cond do
                                  v = options[:timeout][:fg_halt] -> v
                                  is_integer(timeout) -> timeout * 5
                                  :else -> timeout
                                end
                     o = Task.yield(task, timeout)
                     o = o || Task.yield(task, shutdown)
                     o = o || Logger.error("[Noizu.FastGlobal.Cluster] Timeout on write: #{identifier}")
                     # No shutdown just let it proceed so it is eventually populated.
                     Semaphore.release({:fg_write_record, identifier})
                   end
                 )
             end
             value
         end
    else
      cond do
        is_function(default, 1) -> default.(false)
        is_function(default, 0) -> default.()
        :else -> default
      end
      |> case do
           {:fast_global, :no_cache, value} -> value
           value -> value
         end
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
      :no_match ->
        cond do
          Semaphore.acquire({:fg_write_record, identifier}, 1) ->
            Semaphore.release({:fg_write_record, identifier})
            sync_record(identifier, default, options, options[:tsup])
          !is_function(default) ->
            # dummy response no need to pool here, but disable cache overwrite until lock available.
            default = case default do
                        v = {:fast_global, :no_cache, _} -> v
                        v -> {:fast_global, :no_cache, v}
                      end
            sync_record(identifier, default, options, options[:tsup])
          is_function(default,1) ->
            # lock state aware default value provider proceed.
            sync_record(identifier, default, options, options[:tsup])
  
          Semaphore.acquire({:fg_write_record, identifier}, options[:back_pressure][:fg_get_queue] || 500) ->
            # force request to pool briefly while we wait for the write operation to complete
            # to avoid additional db overhead.
            # @todo improve Back pressure handling here.
            Process.sleep(10 + :rand.uniform(25))
            Semaphore.release({:fg_write_record, identifier})
            wait = options[:back_pressure][:fg_get_queue_wait] || 100
            wait = wait + :rand.uniform(div(wait,3))
            cond do
              wait > 50 ->
                Enum.reduce_while(0.. div(wait,25) , false, fn(_,_) ->
                  cond do
                    Semaphore.acquire({:fg_write_record, identifier}, 1) -> {:halt, true}
                    :else ->
                      Process.sleep(25)
                      {:cont, false}
                  end
                end)
              :else ->
                Process.sleep(wait)
                Semaphore.acquire({:fg_write_record, identifier}, 1)
            end
            |> then(fn(mutex) ->
              if mutex || Semaphore.acquire({:fg_write_record, identifier}, 1) do
                Semaphore.release({:fg_write_record, identifier})
                case FastGlobal.get(identifier, :no_match) do
                  %Record{value: v} -> v
                  :no_match -> sync_record(identifier, default, options)
                  error -> error
                end
              else
                # in case the semaphore is released before we reach fg_write insure response here is not cached
                # / does not overwrite existing update.
                default = case default.() do
                            v = {:fast_global, :no_cache, _} -> v
                            v -> {:fast_global, :no_cache, v}
                          end
                sync_record(identifier, default, options)
              end
            end)
          :else ->
            if Semaphore.acquire({:fg_write_record_timeout, :global}, 1) do
              spawn(fn ->
                Logger.error("[Noizu.FastGlobal.Cluster] Pool Overflowing on FG write #{inspect identifier}")
                Process.sleep(100)
                Semaphore.release({:fg_write_record_timeout, :global})
              end)
            end
            # in case the semaphore is released before we reach fg_write insure response here is not cached
            # / does not overwrite existing update.
            default = case default.() do
                        v = {:fast_global, :no_cache, _} -> v
                        v -> {:fast_global, :no_cache, v}
                      end
            sync_record(identifier, default, options)
        end
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
    
    # @TODO we actually need to wait until received, this will fail immedietly if semaphore not acquired.
    Semaphore.call({:fg_update_record, identifier}, 1,
      fn() ->
        Semaphore.call({:fg_write_record, identifier}, 2,
          fn() ->
            Enum.reduce_while(0..2400, false, fn(_,_) ->
              cond do
                Semaphore.acquire({:fg_write_record, identifier}, 2) -> {:halt, true}
                :else ->
                  Process.sleep(25)
                  {:cont, false}
              end
            end)
            |> then(fn(mutex) ->
              with true <- mutex || {:error, :max} do
                Enum.map(update.pool,
                  fn(n) ->
                    try do
                      cond do
                        n == node() -> put(identifier, update, options)
                        :else -> :rpc.cast(n, Noizu.FastGlobal.Cluster, :put, [identifier, update, options])
                      end
                    rescue _ -> {n,:swallow}
                    catch
                      :exit, _ -> {n,:swallow}
                      _ -> {n,:swallow}
                    end
                  end)
                  Semaphore.release({:fg_write_record, identifier})
                else
                error ->
                  Logger.error("[Noizu.FastGlobal.Cluster]: Unable to obtain write for requested update.")
                  error
              end
            end)
          end)
      end)
    
  end
end

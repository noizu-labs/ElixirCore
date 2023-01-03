#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

Application.ensure_started(:semaphore)
Application.ensure_started(:fast_global)

children = [{Task.Supervisor, name: Noizu.FastGlobal.Cluster}]
{:ok, sup} = Supervisor.start_link(children, [strategy: :one_for_one, name: Test.Supervisor, strategy: :one_for_one])

# http://elixir-lang.org/docs/stable/ex_unit/ExUnit.html#start/1
ExUnit.start(capture_log: true)
#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

ExUnit.configure formatters: [JUnitFormatter, ExUnit.CLIFormatter]

# http://elixir-lang.org/docs/stable/ex_unit/ExUnit.html#start/1
ExUnit.start(capture_log: true)
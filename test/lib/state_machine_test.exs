# -------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2023 Noizu Labs, Inc. All rights reserved.
# -------------------------------------------------------------------------------


defmodule Noizu.StateMachineTest do
  use ExUnit.Case, async: false

  @tag :wip_sm
  test "wip" do
    Noizu.TestSM.well(1,2,3,4,5)
  end



end

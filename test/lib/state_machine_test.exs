# -------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2023 Noizu Labs, Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.StateMachineTest do
  use ExUnit.Case, async: false
  require Noizu.StateMachine.Module
  import Noizu.StateMachine.Module

  @moduletag :wip_sm

  describe "verify statemachine state sections" do
    test "global/default implementations" do
      assert :ok_1 == Noizu.TestSM.well(
               nsm(global: %{flag: 1}, local: %{flag: true}),
               :first_a_when_guard,
               :first_b_when_guard,
               :first_c_arg_guard,
               5
             )

      # Insure not incorrectly matched when not all guards met
      assert :catch_all == Noizu.TestSM.well(
               nsm(global: %{flag: false, flag_2: :first_wrapper_inner_wrapper, foo: :error, bop: :fiz}, local: %{flag: :first_wrapper, bop: :boop}),
               :alt_second_a_when_guard,
               :second_b_when_guard,
               :second_c_arg_guard,
               5
             )

      assert :catch_all == Noizu.TestSM.well(
               nsm(global: %{flag_2: :first_wrapper_inner_wrapper, foo: 1, bop: :fiz}, local: %{flag: :not_first_wrapper, bop: :boop}),
               66,
               :second_b_when_guard,
               :second_c_arg_guard,
               5
             )
    end

    test "state_behaviour(nsm(local: %{flag: :first_wrapper})) when (global.foo in [1,2,3] or global.flag == true) : defaults" do

      assert {:ok_2, self(), 999} == Noizu.TestSM.well(
               nsm(global: %{flag_2: :first_wrapper_inner_wrapper, foo: 1, bop: :not_fiz, flag_3: 0xF00}, local: %{flag: :first_wrapper, flag_3: 31337, bop: :boop}),
               999,
               :second_b_when_guard,
               :not_c_alternative,
               5
             )
      assert {:ok_2_catch_all, self(), 99} == Noizu.TestSM.well(
               nsm(global: %{flag_2: :first_wrapper_inner_wrapper, foo: 1, bop: :not_fiz, flag_3: 0xF00}, local: %{flag: :first_wrapper, flag_3: 31337, bop: :boop}),
               99,
               :second_b_when_guard,
               :not_c_alternative,
               5
             )
    end

    test "state -> nested" do


      assert :ok_2_1 == Noizu.TestSM.well(
               nsm(global: %{flag_2: :first_wrapper_inner_wrapper, foo: 1, bop: :fiz}, local: %{flag: :first_wrapper, bop: :boop}),
               :second_a_when_guard,
               :second_b_when_guard,
               :second_c_arg_guard,
               5
             )
      assert :ok_2_1 == Noizu.TestSM.well(
               nsm(global: %{flag_2: :first_wrapper_inner_wrapper, foo: 1, bop: :fiz}, local: %{flag: :first_wrapper, bop: :boop}),
               :alt_second_a_when_guard,
               :second_b_when_guard,
               :second_c_arg_guard,
               5
             )
      assert :ok_2_1 == Noizu.TestSM.well(
               nsm(global: %{flag: true, flag_2: :first_wrapper_inner_wrapper, foo: :error, bop: :fiz}, local: %{flag: :first_wrapper, bop: :boop}),
               :alt_second_a_when_guard,
               :second_b_when_guard,
               :second_c_arg_guard,
               5
             )


      assert :ok_2_1_b == Noizu.TestSM.well(
               nsm(global: %{flag_2: :first_wrapper_inner_wrapper, foo: 1, bop: :fiz}, local: %{flag: :first_wrapper, bop: :boop}),
               :not_second_a_when_guard,
               :second_b_when_guard,
               :c_alternative,
               5
             )

      assert {:ok_2_1_1, self(), 1} == Noizu.TestSM.well(
               nsm(global: %{flag_2: :first_wrapper_inner_wrapper, foo: 1, bop: :fiz, flag_3: 0xF00}, local: %{flag: :first_wrapper, flag_3: 31337, bop: :boop}),
               1,
               :second_b_when_guard,
               :not_c_alternative,
               5
             )

      assert {:ok_2_1_catch_all, self(), 99} == Noizu.TestSM.well(
               nsm(global: %{flag_2: :first_wrapper_inner_wrapper, foo: 1, bop: :fiz, flag_3: 0xF00}, local: %{flag: :first_wrapper, flag_3: 31337, bop: :boop}),
               99,
               :second_b_when_guard,
               :not_c_alternative,
               5
             )
    end

    test "state -> nested -> nested" do

      assert {:ok_2_1_1x, self(), 1} == Noizu.TestSM.well(
               nsm(global: %{flag_2: :first_wrapper_inner_wrapper, foo: 1, bop: :fiz, flag_3: 0xF00, flag_5: :sentinel}, local: %{flag: :first_wrapper, flag_3: 31337, bop: :boop}),
               1,
               :second_b_when_guard,
               :not_c_alternative,
               5
             )

      assert {:ok_2_1_1, self(), 1} == Noizu.TestSM.well(
               nsm(global: %{flag_2: :first_wrapper_inner_wrapper, foo: 1, bop: :fiz, flag_3: 0xF00}, local: %{flag: :first_wrapper, flag_3: 31337, bop: :boop}),
               1,
               :second_b_when_guard,
               :not_c_alternative,
               5
             )
    end
  end
end

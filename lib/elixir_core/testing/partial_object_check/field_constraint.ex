#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.PartialObjectCheck.FieldConstraint do
  @type t :: %__MODULE__{
    assert: :pending | :met | :unmet | :not_applicable,
    required: true | false,
    type_constraint: Noizu.ElixirCore.PartialObjectCheck.TypeConstraint.t | nil,
    value_constraint: Noizu.ElixirCore.PartialObjectCheck.ValueConstraint.t | nil,
   }

  defstruct [
    assert: :pending,
    required: true,
    type_constraint: nil,
    value_constraint: nil
  ]

  def check(%__MODULE__{} = this, sut) do
    cond do
      sut == {Noizu.ElixirCore.PartialObjectCheck, :no_value} ->  %__MODULE__{this| assert: (this.required && :unmet || :not_applicable)}
      true ->
           t = Noizu.ElixirCore.PartialObjectCheck.TypeConstraint.check(this.type_constraint, sut)
           v = Noizu.ElixirCore.PartialObjectCheck.ValueConstraint.check(this.value_constraint, sut)

           t_a = t && t.assert || :not_applicable
           v_a = v && v.assert || :not_applicable

           c = cond do
            t_a == :unmet || v_a == :unmet -> :unmet
            t_a == :pending || v_a == :pending -> :pending
            t_a == :met || v_a == :met -> :met # e.g. at least one field is met, the other may be not_applicable or pending.
            true -> :met
           end
           %__MODULE__{this| assert: c, type_constraint: t, value_constraint: v}
    end
  end
end
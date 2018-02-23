#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.PartialObjectCheck.ValueConstraint do
  @type t :: %__MODULE__{
                assert: :met | :unmet | :pending | :not_applicable,
                constraint: nil | {:value, any} | list | fun,
             }

  defstruct [
    assert: :pending,
    constraint: nil
  ]

  def perform_check(constraint, sut) do
    case constraint do
      nil -> {:not_applicable, constraint}
      v = %Noizu.ElixirCore.PartialObjectCheck{} ->
        uv = Noizu.ElixirCore.PartialObjectCheck.check(v, sut)
        {(uv && uv.assert || :unmet), uv}

      {:value, v} ->
        {(v == sut && :met || :unmet), v}

      {:exact, v} ->
        {(v === sut && :met || :unmet), v}

      v when is_function(v, 1) ->
        c = case v.(sut) do
          true -> :met
          false -> :unmet
          nil -> :unmet
          v -> v
        end
        {c, v}
      v when is_list(v) ->
        Enum.reduce(v, {:not_applicable, []}, fn(c, {c_acc, v_acc}) ->
           {a, c} = perform_check(c, sut)
           ua = cond do
             c_acc == :unmet || a == :unmet -> :unmet
             c_acc == :pending || a == :pending -> :pending
             c_acc == :met || a == :met -> :met
             true -> c_acc
           end
           {ua, v_acc ++ [c]}
        end)
      _ ->
        {:unmet, constraint}
    end
  end

  def check(nil, sut), do: nil
  def check(%__MODULE__{} = this, sut) do
    {a, c} = perform_check(this.constraint, sut)
    %__MODULE__{this| assert: a, constraint: c}
  end

end
#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.PartialObjectCheckTest do
  use ExUnit.Case, async: false
  alias Noizu.ElixirCore.PartialObjectCheck, as: POC
  #alias Noizu.ElixirCore.PartialObjectCheck.FieldConstraint
  #alias Noizu.ElixirCore.PartialObjectCheck.TypeConstraint
  #alias Noizu.ElixirCore.PartialObjectCheck.ValueConstraint
  require Logger

  @tag :testing
  test "IO.inspect check - pass" do
    poc = POC.prepare(%{a: 1, b: 2})
    sut = POC.check(poc, %{a: 1, b: 2})
    sut_str = "#{inspect sut}"
    assert sut_str == "#PartialObjectCheck<%{assert: :met}>"
  end

  @tag :testing
  test "IO.inspect check - field constraint fail" do
    poc = POC.prepare(%{a: 1, b: 2})
    sut = POC.check(poc, %{a: 2, b: 2})
    sut_str = "#{inspect sut, limit: 50}"
    assert sut_str == "#PartialObjectCheck<%{assert: :unmet, field_constraints: %{a: #FieldConstraint<%{assert: :unmet, required: true, value_constraint: #ValueConstraint<%{assert: :unmet, constraint: {:value, 1}}>}>}}>"
  end

  @tag :testing
  test "IO.inspect check - type constraint fail" do
    poc = POC.prepare(%{a: 1, b: 2})
    sut = POC.check(poc, 1)
    sut_str = "#{inspect sut, limit: 50}"
    assert sut_str == "#PartialObjectCheck<%{assert: :unmet, field_constraints: %{a: #FieldConstraint<%{assert: :unmet, required: true}>, b: #FieldConstraint<%{assert: :unmet, required: true}>}, type_constraint: #TypeConstraint<%{assert: :unmet, constraint: {:basic, :map}}>}>"
  end

  @tag :testing
  test "basic functionality - prep for map - 1" do
    sut = POC.prepare(%{a: 1, b: 2})
    assert sut === %POC{
             type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{constraint: {:basic, :map}},
             field_constraints: %{
               a: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{
                 required: true,
                 type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{constraint: {:basic, :integer}},
                 value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{constraint: {:value, 1}}
               },
               b: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{
                 required: true,
                 type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{constraint: {:basic, :integer}},
                 value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{constraint: {:value, 2}}
               }
             }
           }
  end

  @tag :testing
  test "basic functionality - prep for map - 2" do
    sut = POC.prepare(%{a: 1, b: %{}})
    assert sut === %POC{
             type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{constraint: {:basic, :map}},
             field_constraints: %{
               a: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{
                 required: true,
                 type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{constraint: {:basic, :integer}},
                 value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{constraint: {:value, 1}}
               },
               b: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{
                 required: true,
                 type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{constraint: {:basic, :map}},
                 value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: %Noizu.ElixirCore.PartialObjectCheck{assert: :pending, field_constraints: %{}, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :map}}}}
               }
             }
           }
  end

  @tag :testing
  test "basic functionality - prep for struct" do
    sut = POC.prepare(DateTime.from_unix!(100))
    assert sut === %Noizu.ElixirCore.PartialObjectCheck{
             assert: :pending,
             field_constraints: %{
               calendar: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{
                 assert: :pending,
                 required: true,
                 type_constraint: nil,
                 value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: {:value, Calendar.ISO}}},
               day: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{assert: :pending, required: true, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :integer}}, value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: {:value, 1}}},
               hour: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{assert: :pending, required: true, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :integer}}, value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: {:value, 0}}},
               microsecond: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{assert: :pending, required: true, type_constraint: nil, value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: {:value, {0, 0}}}},
               minute: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{assert: :pending, required: true, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :integer}}, value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: {:value, 1}}},
               month: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{assert: :pending, required: true, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :integer}}, value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: {:value, 1}}},
               second: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{assert: :pending, required: true, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :integer}}, value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: {:value, 40}}},
               std_offset: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{assert: :pending, required: true, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :integer}}, value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: {:value, 0}}},
               time_zone: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{assert: :pending, required: true, type_constraint: nil, value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: {:value, "Etc/UTC"}}},
               utc_offset: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{assert: :pending, required: true, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :integer}}, value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: {:value, 0}}},
               year: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{assert: :pending, required: true, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :integer}}, value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: {:value, 1970}}},
               zone_abbr: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{assert: :pending, required: true, type_constraint: nil, value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: {:value, "UTC"}}}}, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:module, DateTime}}}
  end

  @tag :testing
  test "basic functionality - prep for nested struct" do
    sut = POC.prepare(%{a: 1, b: DateTime.from_unix!(100)})

    assert sut === %POC{
             type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{constraint: {:basic, :map}},
             field_constraints: %{
               a: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{
                 required: true,
                 type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{constraint: {:basic, :integer}},
                 value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{constraint: {:value, 1}}
               },
               b: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{
                 required: true,
                 type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{constraint: {:module, DateTime}},
                 value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: %Noizu.ElixirCore.PartialObjectCheck{assert: :pending, field_constraints: %{calendar: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{assert: :pending, required: true, type_constraint: nil, value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: {:value, Calendar.ISO}}}, day: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{assert: :pending, required: true, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :integer}}, value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: {:value, 1}}}, hour: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{assert: :pending, required: true, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :integer}}, value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: {:value, 0}}}, microsecond: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{assert: :pending, required: true, type_constraint: nil, value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: {:value, {0, 0}}}}, minute: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{assert: :pending, required: true, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :integer}}, value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: {:value, 1}}}, month: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{assert: :pending, required: true, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :integer}}, value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: {:value, 1}}}, second: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{assert: :pending, required: true, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :integer}}, value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: {:value, 40}}}, std_offset: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{assert: :pending, required: true, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :integer}}, value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: {:value, 0}}}, time_zone: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{assert: :pending, required: true, type_constraint: nil, value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: {:value, "Etc/UTC"}}}, utc_offset: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{assert: :pending, required: true, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :integer}}, value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: {:value, 0}}}, year: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{assert: :pending, required: true, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :integer}}, value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: {:value, 1970}}}, zone_abbr: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{assert: :pending, required: true, type_constraint: nil, value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: {:value, "UTC"}}}}, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:module, DateTime}}}}
                 }
               }
           }
  end

  @tag :testing
  test "basic functionality - prep with field_constraint override" do
    sut = POC.prepare(%{a: 1, b:  %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{
      required: true,
      type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{constraint: {:basic, :map}},
      value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: %Noizu.ElixirCore.PartialObjectCheck{assert: :pending, field_constraints: %{}, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :map}}}}
    }})
    assert sut === %POC{
             type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{constraint: {:basic, :map}},
             field_constraints: %{
               a: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{
                 required: true,
                 type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{constraint: {:basic, :integer}},
                 value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{constraint: {:value, 1}}
               },
               b: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{
                 required: true,
                 type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{constraint: {:basic, :map}},
                 value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: %Noizu.ElixirCore.PartialObjectCheck{assert: :pending, field_constraints: %{}, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :map}}}}
               }
             }
           }
  end



  @tag :testing
  test "basic functionality - prep with prepobject override" do
    sut = POC.prepare(%{a: 1, b:  %Noizu.ElixirCore.PartialObjectCheck{assert: :pending, field_constraints: %{}, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :map}}} })
    assert sut === %POC{
             type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{constraint: {:basic, :map}},
             field_constraints: %{
               a: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{
                 required: true,
                 type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{constraint: {:basic, :integer}},
                 value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{constraint: {:value, 1}}
               },
               b: %Noizu.ElixirCore.PartialObjectCheck.FieldConstraint{
                 required: true,
                 type_constraint: nil,
                 value_constraint: %Noizu.ElixirCore.PartialObjectCheck.ValueConstraint{assert: :pending, constraint: %Noizu.ElixirCore.PartialObjectCheck{assert: :pending, field_constraints: %{}, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :map}}}}
               }
             }
           }
  end


  @tag :testing
  test "basic functionality - validation - 1" do
    poc = POC.prepare(%{a: 1, b:  %Noizu.ElixirCore.PartialObjectCheck{assert: :pending, field_constraints: %{}, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :map}}} })
    sut = POC.check(poc, %{a: 1, b: %{}})
    assert sut.assert == :met
  end

  @tag :testing
  test "basic functionality - validation - 2" do
    poc = POC.prepare(%{a: 1, b:  %Noizu.ElixirCore.PartialObjectCheck{assert: :pending, field_constraints: %{}, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :map}}} })
    sut = POC.check(poc, %{a: 2, b: %{}})
    assert sut.assert == :unmet
  end

  @tag :testing
  test "basic functionality - validation - 3" do
    poc = POC.prepare(%{a: 1, b:  %Noizu.ElixirCore.PartialObjectCheck{assert: :pending, field_constraints: %{}, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :map}}} })
    sut = POC.check(poc, %{a: 1, b: %{}, c: :apple})
    assert sut.assert == :met
  end

  @tag :testing
  test "basic functionality - validation - 4" do
    poc = POC.prepare(%{a: 1, b:  %Noizu.ElixirCore.PartialObjectCheck{assert: :pending, field_constraints: %{}, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :map}}} })
    sut = POC.check(poc, %{a: 1, b: nil, c: :apple})
    assert sut.assert == :unmet
  end

  @tag :testing
  test "basic functionality - validation - 5" do
    poc = POC.prepare(%{a: 1, b:  %Noizu.ElixirCore.PartialObjectCheck{assert: :pending, field_constraints: %{}, type_constraint: %Noizu.ElixirCore.PartialObjectCheck.TypeConstraint{assert: :pending, constraint: {:basic, :map}}} })
    sut = POC.check(poc, %{a: 1, b: DateTime.from_unix!(0), c: :apple})
    assert sut.assert == :met
  end

  @tag :testing
  test "basic functionality - validation - non required field with constriants" do
    poc = POC.prepare(%{a: 1, b: %{not_required: {POC, :not_required, 12}, required: 6}})

    sut = POC.check(poc, %{a: 1, b: %{required: 6}, c: :apple})
    assert sut.assert == :met
    sut = POC.check(poc, %{a: 1, b: %{not_required: 12, required: 6}, c: :apple})
    assert sut.assert == :met
    sut = POC.check(poc, %{a: 1, b: %{not_required: 14, required: 6}, c: :apple})
    assert sut.assert == :unmet
    sut = POC.check(poc, %{a: 1, b: %{not_required: %{}, required: 6}, c: :apple})
    assert sut.assert == :unmet
  end

  @tag :testing
  test "basic functionality - validation - non required field with out constriants" do
    poc = POC.prepare(%{a: 1, b: %{not_required: {POC, :not_required}, required: 6}})

    sut = POC.check(poc, %{a: 1, b: %{required: 6}, c: :apple})
    assert sut.assert == :met
    sut = POC.check(poc, %{a: 1, b: %{not_required: 12, required: 6}, c: :apple})
    assert sut.assert == :met
    sut = POC.check(poc, %{a: 1, b: %{not_required: 14, required: 6}, c: :apple})
    assert sut.assert == :met
    sut = POC.check(poc, %{a: 1, b: %{not_required: %{}, required: 6}, c: :apple})
    assert sut.assert == :met
  end


  @tag :testing
  test "basic functionality - validation - required field with out constraints" do
    poc = POC.prepare(%{a: 1, b: %{any_value: {POC, [:any_value], %{a: 5}}, required: 6}})

    sut = POC.check(poc, %{a: 1, b: %{any_value: %{}, required: 6}, c: :apple})
    assert sut.assert == :met
    sut = POC.check(poc, %{a: 1, b: %{any_value: %{b: 1}, required: 6}, c: :apple})
    assert sut.assert == :met

    # required
    sut = POC.check(poc, %{a: 1, b: %{any_value: nil, required: 6}, c: :apple})
    assert sut.assert == :unmet

    # type fail
    sut = POC.check(poc, %{a: 1, b: %{any_value: 7, required: 6}, c: :apple})
    assert sut.assert == :unmet
  end



end

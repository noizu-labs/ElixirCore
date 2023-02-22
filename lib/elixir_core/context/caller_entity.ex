#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2020 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.CallerEntity do
  @moduledoc """
  Convenience Noizu.ERP compatible structure for tracking api caller authentication levels.
  Supports :internal, :restricted, :system, :admin
  """

  @vsn 1.0
  use Noizu.ERP.Behaviour,
      handle: "noizu-caller",
      serializer: {Noizu.ERP.Serializer.AtomIdentifier, [constraints: [white_list: [:internal, :restricted, :system, :admin]]]}
  
  @type t :: %__MODULE__{
               identifier: any,
               vsn: float
             }
             
  defstruct [
    identifier: nil,
    vsn: @vsn
  ]
  
  def entity_ok({:ref, __MODULE__, identifier}, _) do
    {:ok, %__MODULE__{identifier: identifier}}
  end
  def entity_ok(ref, options) do
    super(ref, options)
  end

  def entity_ok!({:ref, __MODULE__, identifier}, _) do
    {:ok, %__MODULE__{identifier: identifier}}
  end
  def entity_ok!(ref, options) do
    super(ref, options)
  end
 end

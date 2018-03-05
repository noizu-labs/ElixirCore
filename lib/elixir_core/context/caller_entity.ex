#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.CallerEntity do
  @vsn 1.0

  @type t :: %__MODULE__{
               identifier: any
             }

  defstruct [
    identifier: nil
  ]

  def id(%__MODULE__{} = e), do: e.identifier
  def id({:ref, __MODULE__, identifier}), do: identifier
  def id("ref.noizu-caller." <> identifier), do: to_atom(identifier)
  def id(identifier) when is_atom(identifier), do: identifier

  def ref(%__MODULE__{} = e), do: {:ref, __MODULE__, e.identifier}
  def ref({:ref, __MODULE__, identifier}), do: {:ref, __MODULE__, identifier}
  def ref("ref.noizu-caller." <> identifier), do: {:ref, __MODULE__, to_atom(identifier)}
  def ref(identifier) when is_atom(identifier), do: {:ref, __MODULE__, identifier}

  def sref(%__MODULE__{} = e), do: "ref.noizu-caller.#{e.identifier}"
  def sref({:ref, __MODULE__, identifier}), do: "ref.noizu-caller.#{identifier}"
  def sref("ref.noizu-caller." <> _identifier = sref), do: sref
  def sref(identifier) when is_atom(identifier), do: "ref.noizu-caller.#{identifier}"

  def entity(ref, options \\ %{})
  def entity({:ref, __MODULE__, identifier}, _options), do: %__MODULE__{identifier: identifier}
  def entity(%__MODULE__{} = e, _options), do: e
  def entity("ref.noizu-caller." <> identifier, _options), do: %__MODULE__{identifier: to_atom(identifier)}
  def entity(identifier, _options) when is_atom(identifier), do: %__MODULE__{identifier: identifier}

  def entity!(ref, options \\ %{})
  def entity!({:ref, __MODULE__, identifier}, _options), do: %__MODULE__{identifier: identifier}
  def entity!(%__MODULE__{} = e, _options), do: e
  def entity!("ref.noizu-caller." <> identifier, _options), do: %__MODULE__{identifier: to_atom(identifier)}
  def entity!(identifier, _options) when is_atom(identifier), do: %__MODULE__{identifier: identifier}

  def record(ref, options \\ %{})
  def record({:ref, __MODULE__, identifier}, _options), do: %__MODULE__{identifier: identifier}
  def record(%__MODULE__{} = e, _options), do: e
  def record("ref.noizu-caller." <> identifier, _options), do: %__MODULE__{identifier: to_atom(identifier)}
  def record(identifier, _options) when is_atom(identifier), do: %__MODULE__{identifier: identifier}

  def record!(ref, options \\ %{})
  def record!({:ref, __MODULE__, identifier}, _options), do: %__MODULE__{identifier: identifier}
  def record!(%__MODULE__{} = e, _options), do: e
  def record!("ref.noizu-caller." <> identifier, _options), do: %__MODULE__{identifier: to_atom(identifier)}
  def record!(identifier, _options) when is_atom(identifier), do: %__MODULE__{identifier: identifier}

  def to_atom("internal"), do: :internal
  def to_atom("restricted"), do: :restricted
  def to_atom("system"), do: :system
  def to_atom("admin"), do: :admin




  defimpl Noizu.ERP, for: Noizu.ElixirCore.CallerEntity do
    def id(obj) do
      obj.identifier
    end # end sref/1

    def ref(obj) do
      {:ref, Noizu.ElixirCore.CallerEntity, obj.identifier}
    end # end ref/1

    def sref(obj) do
      "ref.noizu-caller.#{obj.identifier}"
    end # end sref/1

    def record(obj, _options \\ nil) do
      obj
    end # end record/2

    def record!(obj, _options \\ nil) do
      obj
    end # end record/2

    def entity(obj, _options \\ nil) do
      obj
    end # end entity/2

    def entity!(obj, _options \\ nil) do
      obj
    end # end defimpl EntityReferenceProtocol, for: Tuple
  end
 end

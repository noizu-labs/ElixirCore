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
  @type t :: %__MODULE__{
               identifier: any,
               vsn: float
             }

  defstruct [
    identifier: nil,
    vsn: @vsn
  ]


  defp to_atom("internal"), do: :internal
  defp to_atom("restricted"), do: :restricted
  defp to_atom("system"), do: :system
  defp to_atom("admin"), do: :admin

  @doc "Noizu.ERP handler"
  def id(%__MODULE__{} = e), do: e.identifier
  def id({:ref, __MODULE__, identifier}), do: identifier
  def id("ref.noizu-caller." <> identifier), do: to_atom(identifier)
  def id(identifier) when is_atom(identifier), do: identifier

  @doc "Noizu.ERP handler"
  def ref(%__MODULE__{} = e), do: {:ref, __MODULE__, e.identifier}
  def ref({:ref, __MODULE__, identifier}), do: {:ref, __MODULE__, identifier}
  def ref("ref.noizu-caller." <> identifier), do: {:ref, __MODULE__, to_atom(identifier)}
  def ref(identifier) when is_atom(identifier), do: {:ref, __MODULE__, identifier}

  @doc "Noizu.ERP handler"
  def sref(%__MODULE__{} = e), do: "ref.noizu-caller.#{e.identifier}"
  def sref({:ref, __MODULE__, identifier}), do: "ref.noizu-caller.#{identifier}"
  def sref("ref.noizu-caller." <> _identifier = sref), do: sref
  def sref(identifier) when is_atom(identifier), do: "ref.noizu-caller.#{identifier}"

  @doc "Noizu.ERP handler"
  def entity(ref, options \\ %{})
  def entity({:ref, __MODULE__, identifier}, _options), do: %__MODULE__{identifier: identifier}
  def entity(%__MODULE__{} = e, _options), do: e
  def entity("ref.noizu-caller." <> identifier, _options), do: %__MODULE__{identifier: to_atom(identifier)}
  def entity(identifier, _options) when is_atom(identifier), do: %__MODULE__{identifier: identifier}

  @doc "Noizu.ERP handler"
  def entity!(ref, options \\ %{})
  def entity!({:ref, __MODULE__, identifier}, _options), do: %__MODULE__{identifier: identifier}
  def entity!(%__MODULE__{} = e, _options), do: e
  def entity!("ref.noizu-caller." <> identifier, _options), do: %__MODULE__{identifier: to_atom(identifier)}
  def entity!(identifier, _options) when is_atom(identifier), do: %__MODULE__{identifier: identifier}

  @doc "Noizu.ERP handler"
  def record(ref, options \\ %{})
  def record({:ref, __MODULE__, identifier}, _options), do: %__MODULE__{identifier: identifier}
  def record(%__MODULE__{} = e, _options), do: e
  def record("ref.noizu-caller." <> identifier, _options), do: %__MODULE__{identifier: to_atom(identifier)}
  def record(identifier, _options) when is_atom(identifier), do: %__MODULE__{identifier: identifier}

  @doc "Noizu.ERP handler"
  def record!(ref, options \\ %{})
  def record!({:ref, __MODULE__, identifier}, _options), do: %__MODULE__{identifier: identifier}
  def record!(%__MODULE__{} = e, _options), do: e
  def record!("ref.noizu-caller." <> identifier, _options), do: %__MODULE__{identifier: to_atom(identifier)}
  def record!(identifier, _options) when is_atom(identifier), do: %__MODULE__{identifier: identifier}

  @doc "Noizu.ERP handler"
  def id_ok(o) do
    r = id(o)
    r && {:ok, r} || {:error, o}
  end

  @doc "Noizu.ERP handler"
  def ref_ok(o) do
    r = ref(o)
    r && {:ok, r} || {:error, o}
  end

  @doc "Noizu.ERP handler"
  def sref_ok(o) do
    r = sref(o)
    r && {:ok, r} || {:error, o}
  end

  @doc "Noizu.ERP handler"
  def entity_ok(o, options \\ %{}) do
    r = entity(o, options)
    r && {:ok, r} || {:error, o}
  end

  @doc "Noizu.ERP handler"
  def entity_ok!(o, options \\ %{}) do
    r = entity!(o, options)
    r && {:ok, r} || {:error, o}
  end

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


    def id_ok(o) do
      r = id(o)
      r && {:ok, r} || {:error, o}
    end
    def ref_ok(o) do
      r = ref(o)
      r && {:ok, r} || {:error, o}
    end
    def sref_ok(o) do
      r = sref(o)
      r && {:ok, r} || {:error, o}
    end
    def entity_ok(o, options \\ %{}) do
      r = entity(o, options)
      r && {:ok, r} || {:error, o}
    end
    def entity_ok!(o, options \\ %{}) do
      r = entity!(o, options)
      r && {:ok, r} || {:error, o}
    end

  end
 end

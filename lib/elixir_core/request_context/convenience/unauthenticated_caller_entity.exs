#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.UnauthenticatedCallerEntity do
  @moduledoc """
  Noizu.ElixirCore.UnauthenticatedCallerEntity
  ==================================
  Convenience Noizu.ERP compatible structure for tracking unauthenticated api callers in Noizu.ElixirCore.CallingContext with Noizu.ERP protocol support.
  Identifier is generally expected to be a IP address or other string.

  """
  
  #==================================================
  # Imports
  #==================================================
  alias Noizu.Types, as: T

  #==================================================
  # Struct
  #==================================================
  @vsn 1.0

  @type t :: %__MODULE__{
               identifier: :internal | :restricted | :system | :admin | atom,
               vsn: float
             }

  defstruct [
    identifier: nil,
    vsn: @vsn
  ]

  #==================================================
  # Attributes
  #==================================================
  @sref_prefix "noizu-unauthenticated"

  #==================================================
  # Methods
  #==================================================

  #-----------------
  # __string_to_id__/2
  #-----------------
  @doc """
    Following syntax from noizu advanced scaffolding library
  """
  @spec __string_to_id__(String.t, term) :: {:ok, T.erp_id(atom)} | {:error, term}
  def __string_to_id__(serialized_identifier, constraints \\ nil)
  def __string_to_id__(serialized_identifier,_) do
    {:ok, serialized_identifier}
  end

  #--------------------------------------------------
  # Noizu.ERP providers
  #--------------------------------------------------

  #-----------------
  # id/1
  #-----------------
  @spec id(T.entity_reference(__MODULE__) | any) :: T.erp_id(atom) | nil
  def id(ref), do: unwrap(id_ok(ref))

  #-----------------
  # ref/1
  #-----------------
  @spec ref(T.entity_reference(__MODULE__) | any) :: T.erp_ref(__MODULE__) | nil
  def ref(ref), do: unwrap(ref_ok(ref))

  #-----------------
  # sref/1
  #-----------------
  @spec sref(T.entity_reference(__MODULE__) | any) :: T.erp_sref() | nil
  def sref(ref), do: unwrap(sref_ok(ref))

  #-----------------
  # entity/2
  #-----------------
  @spec entity(T.entity_reference(__MODULE__) | any) :: T.erp_entity(__MODULE__) | nil
  @spec entity(T.entity_reference(__MODULE__) | any, T.erp_options) :: T.erp_entity(__MODULE__) | nil
  def entity(ref, _ \\ nil), do: unwrap(entity_ok(ref))

  #-----------------
  # entity!/2
  #-----------------
  @spec entity!(T.entity_reference(__MODULE__) | any) :: T.erp_entity(__MODULE__) | nil
  @spec entity!(T.entity_reference(__MODULE__) | any, T.erp_options) :: T.erp_entity(__MODULE__) | nil
  def entity!(ref, _ \\ nil), do: unwrap(entity_ok(ref))

  #-----------------
  # record/2
  #-----------------
  @spec record(T.entity_reference(__MODULE__) | any) :: T.erp_entity(__MODULE__) | nil
  @spec record(T.entity_reference(__MODULE__) | any, T.erp_options) :: T.erp_entity(__MODULE__) | nil
  def record(ref, _ \\ nil), do: unwrap(entity_ok(ref))

  #-----------------
  # record!/2
  #-----------------
  @spec record!(T.entity_reference(__MODULE__) | any) :: T.erp_entity(__MODULE__) | nil
  @spec record!(T.entity_reference(__MODULE__) | any, T.erp_options) :: T.erp_entity(__MODULE__) | nil
  def record!(ref, _ \\ nil), do: unwrap(entity_ok(ref))

  #-----------------
  # id_ok/1
  #-----------------
  @spec id_ok(T.entity_reference(__MODULE__) | any) :: {:ok, T.erp_id(atom)} | {:error, term}
  def id_ok(ref) do
    with {:ok, {:ref, __MODULE__, identifier}} <- ref_ok(ref) do
      {:ok, identifier}
    end
  end

  #-----------------
  # ref_ok/1
  #-----------------
  @spec ref_ok(T.entity_reference(__MODULE__) | any) :: {:ok, T.erp_ref(__MODULE__)} | {:error, term}
  def ref_ok({:ref, __MODULE__, _} = ref), do: {:ok, ref}
  def ref_ok("ref.noizu-unauthenticated." <> identifier), do: ref_ok(identifier)
  def ref_ok("ref." <> _ = ref), do: {:error, {:unsupported_identifier, ref}}
  def ref_ok(ref) when is_bitstring(ref) do
    with {:ok, identifier} <- __string_to_id__(ref), do: {:ok, {:ref, __MODULE__, identifier}}
  end
  def ref_ok(%__MODULE__{identifier: identifier}), do: {:ok, {:ref, __MODULE__, identifier}}
  def ref_ok(ref), do: {:error, {:unsupported, ref}}

  #-----------------
  # sref_ok/1
  #-----------------
  @spec sref_ok(T.entity_reference(__MODULE__) | any) :: {:ok, T.erp_sref()} | {:error, term}
  def sref_ok(ref) do
    with {:ok, {:ref, __MODULE__, identifier}} <- ref_ok(ref) do
      {:ok, "ref.#{@sref_prefix}.#{identifier}"}
    end
  end

  #-----------------
  # entity_ok/2
  #-----------------
  @spec entity_ok(T.entity_reference(__MODULE__) | any) :: {:ok, T.erp_entity(__MODULE__)} | {:error, term}
  @spec entity_ok(T.entity_reference(__MODULE__) | any, T.erp_options) :: {:ok, T.erp_entity(__MODULE__)} | {:error, term}
  def entity_ok(ref, _ \\ nil)
  def entity_ok(%__MODULE__{} = ref, _), do: {:ok, ref}
  def entity_ok(ref, _) do
    with {:ok, {:ref, __MODULE__, identifier}} <- ref_ok(ref) do
      {:ok, %__MODULE__{identifier: identifier}}
    end
  end

  #-----------------
  # entity_ok!/2
  #-----------------
  @spec entity_ok!(T.entity_reference(__MODULE__) | any) :: {:ok, T.erp_entity(__MODULE__)} | {:error, term}
  @spec entity_ok!(T.entity_reference(__MODULE__) | any, T.erp_options) :: {:ok, T.erp_entity(__MODULE__)} | {:error, term}
  def entity_ok!(ref, _ \\ nil), do: entity_ok(ref)

  #==================================================
  # Private Methods
  #==================================================
  @spec unwrap({:ok, any} | any) :: any | nil
  defp unwrap({:ok, v}), do: v
  defp unwrap(_), do: nil
end

#==================================================
# Noizu.ERP
#==================================================
defimpl Noizu.ERP, for: Noizu.ElixirCore.UnauthenticatedCallerEntity do
  defdelegate id(ref), to: Noizu.ElixirCore.UnauthenticatedCallerEntity
  defdelegate ref(ref), to: Noizu.ElixirCore.UnauthenticatedCallerEntity
  defdelegate sref(ref), to: Noizu.ElixirCore.UnauthenticatedCallerEntity
  defdelegate entity(ref, options \\ nil), to: Noizu.ElixirCore.UnauthenticatedCallerEntity
  defdelegate entity!(ref, options \\ nil), to: Noizu.ElixirCore.UnauthenticatedCallerEntity
  defdelegate record(ref, options \\ nil), to: Noizu.ElixirCore.UnauthenticatedCallerEntity
  defdelegate record!(ref, options \\ nil), to: Noizu.ElixirCore.UnauthenticatedCallerEntity
  
  defdelegate id_ok(ref), to: Noizu.ElixirCore.UnauthenticatedCallerEntity
  defdelegate ref_ok(ref), to: Noizu.ElixirCore.UnauthenticatedCallerEntity
  defdelegate sref_ok(ref), to: Noizu.ElixirCore.UnauthenticatedCallerEntity
  defdelegate entity_ok(ref, options \\ nil), to: Noizu.ElixirCore.UnauthenticatedCallerEntity
  defdelegate entity_ok!(ref, options \\ nil), to: Noizu.ElixirCore.UnauthenticatedCallerEntity
end

#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2023 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.ERP.Serializer.AtomIdentifier do
  require Noizu.ERP.Serializer.Behaviour
  
  def __string_to_id__(mod, term) do
    with Noizu.ERP.Serializer.Behaviour.erp_serializer_config(constraints: c) <- __erp_serializer__(mod) do
      cond do
        wl = c[:white_list] ->
          cond do
            Enum.find(wl, &(Atom.to_string(&1) == term)) -> {:ok, String.to_atom(term)}
            :else -> {:error, {:not_in_white_list, term}}
          end
        c[:existing] -> String.to_existing_atom(term)
        c[:any] -> String.to_atom(term)
        :else -> {:error, {:serializer_config, :invalid}}
      end
    else
      _ -> {:error, {:serialize_config, :invalid}}
    end
  end
  def __id_to_string__(mod, term) do
    with Noizu.ERP.Serializer.Behaviour.erp_serializer_config(constraints: c) <- __erp_serializer__(mod) do
      cond do
        wl = c[:white_list] ->
          cond do
            Enum.member?(wl, term) -> {:ok, Atom.to_string(term)}
            :else -> {:error, {:not_in_white_list, term}}
          end
        c[:existing] -> Atom.to_string(term)
        c[:any] ->  Atom.to_string(term)
        :else -> {:error, {:serializer_config, :invalid}}
      end
    else
      _ -> {:error, {:serialize_config, :invalid}}
    end
  end
  
  def __valid_identifier__(_, true), do: {:error, {:bool, :unsupported_identifier}}
  def __valid_identifier__(_, false), do: {:error, {:bool, :unsupported_identifier}}
  def __valid_identifier__(_, nil), do: {:error, {nil, :unsupported_identifier}}
  def __valid_identifier__(mod, term) when is_bitstring(term) do
    with Noizu.ERP.Serializer.Behaviour.erp_serializer_config(constraints: c) <- __erp_serializer__(mod) do
      cond do
        wl = c[:white_list] ->
          cond do
            Enum.find(wl, &(Atom.to_string(&1) == term)) -> :ok
            :else -> {:error, {:not_in_white_list, term}}
          end
        c[:existing] -> :ok
        c[:any] -> :ok
        :else -> {:error, {:serializer_config, :invalid}}
      end
    else
      _ -> {:error, {:serialize_config, :invalid}}
    end
  end
  def __valid_identifier__(mod, term) when is_atom(term) do
    with Noizu.ERP.Serializer.Behaviour.erp_serializer_config(constraints: c) <- __erp_serializer__(mod) do
      cond do
        wl = c[:white_list] ->
          cond do
            Enum.member?(wl, term) -> :ok
            :else -> {:error, {:not_in_white_list, term}}
          end
        c[:existing] -> :ok
        c[:any] ->  :ok
        :else -> {:error, {:serializer_config, :invalid}}
      end
    else
      _ -> {:error, {:serialize_config, :invalid}}
    end
  end
  def __erp_serializer__(mod), do: apply(mod, :__erp_serializer__, [])
  
  defmacro __using__(options \\ nil) do
    quote do
      require Noizu.ERP.Serializer.Behaviour
      @__erp_config__ Noizu.ERP.Serializer.Behaviour.erp_serializer_config(
                        provider: Noizu.ERP.Serializer.AtomIdentifier,
                        module: __MODULE__,
                        handle: unquote(options)[:handle],
                        settings: unquote(options)[:settings] || [],
                        constraints: unquote(options)[:constraints] || [existing: true]
                      )
      def __erp_serializer__(), do: @__erp_config__
    end
  end


end
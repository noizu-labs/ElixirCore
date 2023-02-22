#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2023 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.ERP.Dispatcher.Behaviour.Simple do
  @behaviour Noizu.ERP.Dispatcher.Behaviour
  require Noizu.ERP.Serializer.Behaviour
  def id_ok(mod, {:ref, mod, identifier}) do
    {:ok, identifier}
  end
  def id_ok(mod, %{__struct__: mod, identifier: identifier}) do
    {:ok, identifier}
  end
  def id_ok(_mod, _ref) do
    {:error, :nyi}
  end
  
  def ref_ok(mod, {:ref, mod, _identifier} = ref) do
    {:ok, ref}
  end
  def ref_ok(mod, %{__struct__: mod, identifier: identifier}) do
    {:ok, {:ref, mod, identifier}}
  end
  def ref_ok(_mod, _ref) do
    {:error, :nyi}
  end

  def sref_ok(mod, {:ref, mod, identifier} = _ref) do
    with Noizu.ERP.Serializer.Behaviour.erp_serializer_config(provider: c, handle: h, module: m) <- apply(mod, :__erp_serializer__, []),
         :ok <- apply(c, :__valid_identifier__, [m, identifier]),
         {:ok, s} <- apply(c, :__id_to_string__, [m, identifier]) do
      {:ok, "ref.#{h}.#{s}"}
    end
  end
  def sref_ok(mod, %{__struct__: mod, identifier: identifier}) do
    with Noizu.ERP.Serializer.Behaviour.erp_serializer_config(provider: c, handle: h, module: m) <- apply(mod, :__erp_serializer__, []),
         :ok <- apply(c, :__valid_identifier__, [m, identifier]),
         {:ok, s} <- apply(c, :__id_to_string__, [m, identifier]) do
      {:ok, "ref.#{h}.#{s}"}
    end
  end
  def sref_ok(_mod, _ref) do
    {:error, :nyi}
  end

  def entity_ok(mod, e = %{__struct__: mod, identifier: _}, _) do
    {:ok, e}
  end
  def entity_ok(_mod, _ref, _) do
    {:error, :nyi}
  end

  def entity_ok!(mod, e = %{__struct__: mod, identifier: _}, _) do
    {:ok, e}
  end
  def entity_ok!(_mod, _ref, _options, _) do
    {:error, :nyi}
  end
  
  def id(mod, ref) do
    with {:ok, x} <- apply(mod, :id_ok, [ref]) do
      x
    else
      _ -> nil
    end
  end
  def ref(mod, ref) do
    with {:ok, x} <- apply(mod, :ref_ok, [ref]) do
      x
    else
      _ -> nil
    end
  end
  def sref(mod, ref) do
    with {:ok, x} <- apply(mod, :sref_ok, [ref]) do
      x
    else
      _ -> nil
    end
  end
  def entity(mod, ref, options) do
    with {:ok, x} <- apply(mod, :entity_ok, [ref, options]) do
      x
    else
      _ -> nil
    end
  end
  def entity!(mod, ref, options) do
    with {:ok, x} <- apply(mod, :entity_ok!, [ref, options]) do
      x
    else
      _ -> nil
    end
  end
  
end
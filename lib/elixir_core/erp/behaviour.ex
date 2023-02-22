#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2023 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.ERP.Behaviour do
  @type options :: Map.t | term | nil
  @type context :: term
  @type ref :: {:ref, module, term}
  @type response_tuple(type) :: {:ok, type} | {:error, term}
  
  @callback id_ok(term) :: response_tuple(any)
  @callback ref_ok(term) :: response_tuple(ref)
  @callback sref_ok(term) :: response_tuple(String.t)
  @callback entity_ok(term) :: response_tuple(struct)
  @callback entity_ok(term, options) :: response_tuple(struct)
  @callback entity_ok!(term) :: response_tuple(struct)
  @callback entity_ok!(term, options) :: response_tuple(struct)

  @callback id(term) :: any | nil
  @callback ref(term) :: ref | nil
  @callback sref(term) :: String.t | nil
  @callback entity(term) :: struct
  @callback entity(term, options) :: struct
  @callback entity!(term) :: struct
  @callback entity!(term, options) :: struct


  defmacro __dispatch_block__(dispatcher) do
    quote bind_quoted: [dispatcher: dispatcher] do
      @dispatcher dispatcher
      def id_ok(ref), do: apply(@dispatcher, :id_ok, [__MODULE__, ref])
      def ref_ok(ref), do: apply(@dispatcher, :ref_ok, [__MODULE__, ref])
      def sref_ok(ref), do: apply(@dispatcher, :sref_ok, [__MODULE__, ref])
      def entity_ok(ref), do: entity_ok(ref, %{})
      def entity_ok(ref, options), do: apply(@dispatcher, :entity_ok, [__MODULE__, ref, options])
      def entity_ok!(ref), do: entity_ok!(ref, %{})
      def entity_ok!(ref, options), do: apply(@dispatcher, :entity_ok!, [__MODULE__, ref, options])
      
      def id(ref), do: apply(@dispatcher, :id, [__MODULE__, ref])
      def ref(ref), do: apply(@dispatcher, :ref, [__MODULE__, ref])
      def sref(ref), do: apply(@dispatcher, :sref, [__MODULE__, ref])
      def entity(ref), do: entity(ref, %{})
      def entity(ref, options), do: apply(@dispatcher, :entity, [__MODULE__, ref, options])
      def entity!(ref), do: entity!(ref, %{})
      def entity!(ref, options), do: apply(@dispatcher, :entity!, [__MODULE__, ref, options])

      @derive Noizu.ERP
      defoverridable [
        id_ok: 1,
        ref_ok: 1,
        sref_ok: 1,
        entity_ok: 1,
        entity_ok: 2,
        entity_ok!: 1,
        entity_ok!: 2,
        id: 1,
        ref: 1,
        sref: 1,
        entity: 1,
        entity: 2,
        entity!: 1,
        entity!: 2,
      ]
    end
  end


  defmacro __using__(options \\ nil) do
    serializer_handle = Module.get_attribute(__CALLER__.module, :sref_module, options[:handle])
    provider = Module.get_attribute(__CALLER__.module, :erp_provider, options[:provider])
    {serializer, serializer_opts} = Module.get_attribute(__CALLER__.module, :erp_serializer, options[:serializer])
                                    |> case do
                                         {p,o} -> {p,o}
                                         p -> {p, []}
                                       end
    quote do
      @behaviour Noizu.ERP.Behaviour
      @provider unquote(provider) || Noizu.ERP.Dispatcher.Behaviour.Simple
      require Noizu.ERP.Behaviour
      
      use unquote(serializer),
          unquote(serializer_opts) ++ [{:handle, unquote(serializer_handle)}]
      Noizu.ERP.Behaviour.__dispatch_block__(@provider)
    end
  end
  
end

defmodule Noizu.ERP.Behaviour do
  @type options :: Map.t | term | nil
  @type context :: term
  @type ref :: {:ref, module, term}
  @type response_tuple(type) :: {:ok, type} || {:error, term}
  
  @callback __sref_config__() :: [{:serializer, module}, {:sref_module, String.t}, {:config, term | nil}]
  @callback __erp_dispatch__() :: module
  
  @callback id_ok(term) :: response_tuple(any)
  @callback ref_ok(term) :: response_tuple(ref)
  @callback sref_ok(term) :: response_tuple(String.t)
  @callback entity_ok(term, options \\ nil) :: response_tuple(struct)
  @callback create_ok(term, context, options \\ nil) :: response_tuple(struct)
  @callback update_ok(term, context, options \\ nil) :: response_tuple(struct)
  @callback entity_ok!(term, options \\ nil) :: response_tuple(struct)
  @callback create_ok!(term, context, options \\ nil) :: response_tuple(struct)
  @callback update_ok!(term, context, options \\ nil) :: response_tuple(struct)

  @callback id(term) :: any | nil
  @callback ref(term) :: ref | nil
  @callback sref(term) :: String.t | nil
  @callback entity(term, options \\ nil) :: struct
  @callback create(term, context, options \\ nil) :: struct
  @callback update(term, context, options \\ nil) :: struct
  @callback entity!(term, options \\ nil) :: struct
  @callback create!(term, context, options \\ nil) :: struct
  @callback update!(term, context, options \\ nil) :: struct

  defmacro __dispatch_block__(dispatcher) do
    quote bind_quoted: [dispatcher: dispatcher] do
      def __erp_dispatch__(), do: {:ok, __MODULE__}
      def id_ok(ref), do: apply(dispatcher, :id_ok, [__MODULE__, ref])
      def ref_ok(ref), do: apply(dispatcher, :ref_ok, [__MODULE__, ref])
      def sref_ok(ref), do: apply(dispatcher, :sref_ok, [__MODULE__, ref])
      def entity_ok(ref, options \\ nil), do: apply(dispatcher, :entity_ok, [__MODULE__, ref, options])
      def entity_ok!(ref, options \\ nil), do: apply(dispatcher, :entity_ok!, [__MODULE__, ref, options])
      def create_ok(ref, context, options \\ nil), do: apply(dispatcher, :create_ok, [__MODULE__, ref, context, options])
      def create_ok!(ref, context, options \\ nil), do: apply(dispatcher, :create_ok!, [__MODULE__, ref, context, options])
      def update_ok(ref, context, options \\ nil), do: apply(dispatcher, :update_ok, [__MODULE__, ref, context, options])
      def update_ok!(ref, context, options \\ nil), do: apply(dispatcher, :update_ok!, [__MODULE__, ref, context, options])

      def id(ref), do: apply(dispatcher, :id, [__MODULE__, ref])
      def ref(ref), do: apply(dispatcher, :ref, [__MODULE__, ref])
      def sref(ref), do: apply(dispatcher, :sref, [__MODULE__, ref])
      def entity(ref, options \\ nil), do: apply(dispatcher, :entity, [__MODULE__, ref, options])
      def entity!(ref, options \\ nil), do: apply(dispatcher, :entity!, [__MODULE__, ref, options])
      def create(ref, context, options \\ nil), do: apply(dispatcher, :create, [__MODULE__, ref, context, options])
      def create!(ref, context, options \\ nil), do: apply(dispatcher, :create!, [__MODULE__, ref, context, options])
      def update(ref, context, options \\ nil), do: apply(dispatcher, :update, [__MODULE__, ref, context, options])
      def update!(ref, context, options \\ nil), do: apply(dispatcher, :update!, [__MODULE__, ref, context, options])
      
      def overridable [
        #__erp_dispatch__: 1,
        id_ok: 1,
        ref_ok: 1,
        sref_ok: 1,
        entity_ok: 1,
        entity_ok: 2,
        entity_ok!: 1,
        entity_ok!: 2,
        create_ok!: 2,
        create_ok!: 3,
        update_ok: 2,
        update_ok: 3,
        update_ok!: 2,
        update_ok!: 3,
        id: 1,
        ref: 1,
        sref: 1,
        entity: 1,
        entity: 2,
        entity!: 1,
        entity!: 2,
        record: 1,
        record: 2,
        record!: 1,
        record!: 2,
        create: 2,
        create: 3,
        create!: 2,
        create!: 3,
        update: 2,
        update: 3,
        update!: 2,
        update!: 3,
      ]
    end
  end
  
  defmacro __using__(options \\ nil) do
    sref = Module.get_attribute?(__CALLER__.module, :sref_module, options[:sref])
    id_serializer = Module.get_attribute?(__CALLER__.module, :id_serializer, options[:id_serializer] || Noizu.ERP.Serializer.Behaviour.Default)
    sref_config = [
      sref: sref,
      serializer: id_serializer,
      config: nil,
      supported: sref && true || false
    ]
    erp_handler = Module.get_attribute?(__CALLER__.module, :erp_handler, options[:erp_handler] || Noizu.ERP.Dispatcher.Behaviour.Default)
    
    quote bind_quoted: [sref_config: sref_config, erp_handler: erp_handler]  do
      @behaviour Noizu.ERP.Behaviour
      require Noizu.ERP.Behaviour
      def __sref_config__(), do: sref_config
      Noizu.ERP.Behaviour.__dispatch_block__(erp_handler)
    end
  end
end


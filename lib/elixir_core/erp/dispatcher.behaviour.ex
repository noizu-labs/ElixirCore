
defmodule Noizu.ERP.Dispatcher.Behaviour do
  @type options :: Map.t | term | nil
  @type context :: term
  @type ref :: {:ref, module, term}
  @type response_tuple(type) :: {:ok, type} || {:error, term}
  
  @callback id_ok(module, term) :: response_tuple(any)
  @callback ref_ok(module, term) :: response_tuple(ref)
  @callback sref_ok(module, term) :: response_tuple(String.t)
  @callback entity_ok(module, term, options \\ nil) :: response_tuple(struct)
  @callback create_ok(module, term, context, options \\ nil) :: response_tuple(struct)
  @callback update_ok(module, term, context, options \\ nil) :: response_tuple(struct)
  @callback entity_ok!(module, term, options \\ nil) :: response_tuple(struct)
  @callback create_ok!(module, term, context, options \\ nil) :: response_tuple(struct)
  @callback update_ok!(module, term, context, options \\ nil) :: response_tuple(struct)
  
  @callback id(module, term) :: any | nil
  @callback ref(module, term) :: ref | nil
  @callback sref(module, term) :: String.t | nil
  @callback entity(module, term, options \\ nil) :: struct
  @callback create(module, term, context, options \\ nil) :: struct
  @callback update(module, term, context, options \\ nil) :: struct
  @callback entity!(module, term, options \\ nil) :: struct
  @callback create!(module, term, context, options \\ nil) :: struct
  @callback update!(module, term, context, options \\ nil) :: struct
  
  defmodule Default do
  
    def id_ok(module, ref) do
      with {:ok, {_, _, id}} <- apply(module, :ref_ok, [ref]) do
        {:ok, id}
      end
    end
    def ref_ok(module, ref) do
      case ref do
        s when is_bitstring(s) ->
          cond do
               p = apply(module, :__sref_config__)[:serializer]  -> apply(p, :__string_to_ref__, [module, ref])
               :else -> {:error, {:ref,  {:unsupported, ref}}}
          end
        %{__struct__: ^module, identifier: id} ->
          cond do
            id == nil -> {:error, {:ref, :is_nil}}
            :else ->
              # is valid check should go here.
              {:ref, module, id}
          end
      end
    end
    
    
    @callback ref_ok(module, term) :: response_tuple(ref)
    @callback sref_ok(module, term) :: response_tuple(String.t)
    @callback entity_ok(module, term, options \\ nil) :: response_tuple(struct)
    @callback create_ok(module, term, context, options \\ nil) :: response_tuple(struct)
    @callback update_ok(module, term, context, options \\ nil) :: response_tuple(struct)
    @callback entity_ok!(module, term, options \\ nil) :: response_tuple(struct)
    @callback create_ok!(module, term, context, options \\ nil) :: response_tuple(struct)
    @callback update_ok!(module, term, context, options \\ nil) :: response_tuple(struct)
  
    @callback id(module, term) :: any | nil
    @callback ref(module, term) :: ref | nil
    @callback sref(module, term) :: String.t | nil
    @callback entity(module, term, options \\ nil) :: struct
    @callback create(module, term, context, options \\ nil) :: struct
    @callback update(module, term, context, options \\ nil) :: struct
    @callback entity!(module, term, options \\ nil) :: struct
    @callback create!(module, term, context, options \\ nil) :: struct
    @callback update!(module, term, context, options \\ nil) :: struct
    
    
  end
end

defmodule Noizu.ERP.Serializer.Behaviour do
  @type options :: Map.t | term | nil
  @type context :: term
  @type ref :: {:ref, module, term}
  @type response_tuple(type) :: {:ok, type} || {:error, term}
  
  @callback __string_to_id__(module, String.t) :: response_tuple(term)
  @callback __id_to_string__(module, term) :: response_tuple(String.t)
  @callback __valid_identifier__(module, term) :: :ok | {:error, term}
  @callback __sref_module__(module) :: response_tuple(String.t)
  @callback __sref_config__(module) :: response_tuple(any)
  
  defmodule Default do
    def __string_to_id__(m, sid) when is_bitstring(sid) do
      case Integer.parse(sid) do
        {id, ""} -> {:ok, id}
        e -> {:error, {:identifier, {:invalid, sid}}}
      end
    end
    def __string_to_id__(_, sid) do
      {:error, {:identifier, {:invalid, sid}}}
    end
    
    def __id_to_string__(_, id) when is_integer(id)  do
      {:ok, Integer.to_string(id)}
    end
    def __id_to_string__(_, id) do
      {:error, {:identifier, {:invalid, id}}}
    end
    
    def __valid_identifier__(_, id) when is_integer(id), do: :ok
    def __valid_identifier__(_, id), do: {:error, {:identifier, {:invalid, id}}}
    
    def __sref_module__(m), do: apply(m, :__sref_module__, [])
    def __sref_config__(m), do: apply(m, :__sref_config__, [])
  end

end

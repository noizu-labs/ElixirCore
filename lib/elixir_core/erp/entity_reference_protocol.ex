#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------
defprotocol Noizu.ERP do
  @fallback_to_any true
  alias Noizu.Types, as: T

  @doc "Get underlying id for ref"
  @spec id(any) :: list(T.erp_id()) | T.erp_id() | nil
  def id(obj)
  @doc "Get underlying id for ref, return as {:ok, value} or {:error, error}"
  @spec id_ok(any) :: {:ok, list(T.erp_id()) | T.erp_id()} | {:error, term}
  def id_ok(obj)

  @doc "Cast to noizu reference object"
  @spec ref(any) :: list(T.erp_ref()) | T.erp_ref() | nil
  def ref(obj)
  @doc "Cast to noizu reference object, return as {:ok, value} or {:error, error}"
  @spec ref_ok(any) :: {:ok, list(T.erp_ref()) | T.erp_ref()} | {:error, term}
  def ref_ok(obj)

  @doc "Cast to noizu string reference object"
  @spec sref(any) :: list(T.erp_sref()) | T.erp_sref() | nil
  def sref(obj)
  @doc "Cast to noizu string reference object, return as {:ok, value} or {:error, error}"
  @spec sref_ok(any) :: {:ok, list(T.erp_sref()) | T.erp_sref()} | {:error, term}
  def sref_ok(obj)

  @doc "Convert to persistence object. Options may be passed to coordinate actions like expanding embedded references."
  @spec record(any) :: list(T.erp_entity()) | T.erp_entity() | nil
  @spec record(any, T.erp_options()) :: list(T.erp_entity()) | T.erp_entity() | nil
  def record(obj, options \\ %{})

  @doc "Convert to persistence object Options may be passed to coordinate actions like expanding embedded references. (With transaction wrapper if required)"
  @spec record!(any) :: list(T.erp_entity()) | T.erp_entity() | nil
  @spec record!(any, T.erp_options()) :: list(T.erp_entity()) | T.erp_entity() | nil
  def record!(obj, options \\ %{})

  @doc "Convert to scaffolding.struct object. Options may be passed to coordinate actions like expanding embedded references."
  @spec entity(any) :: list(T.erp_entity()) | T.erp_entity() | nil
  @spec entity(any, T.erp_options()) :: list(T.erp_entity()) | T.erp_entity() | nil
  def entity(obj, options \\ %{})
  @doc "Convert to scaffolding.struct object. Options may be passed to coordinate actions like expanding embedded references, return as {:ok, value} or {:error, error}"
  @spec entity_ok(any) :: {:ok, list(T.erp_entity()) | T.erp_entity()} | {:error, term}
  @spec entity_ok(any, T.erp_options()) :: {:ok, list(T.erp_entity()) | T.erp_entity()} | {:error, term}
  def entity_ok(obj, options \\ %{})

  @doc "Convert to scaffolding.struct object Options may be passed to coordinate actions like expanding embedded references. (With transaction wrapper if required)"
  @spec entity!(any) :: list(T.erp_entity()) | T.erp_entity() | nil
  @spec entity!(any, T.erp_options()) :: list(T.erp_entity()) | T.erp_entity() | nil
  def entity!(obj, options \\ %{})
  @doc "Convert to scaffolding.struct object Options may be passed to coordinate actions like expanding embedded references. (With transaction wrapper if required), return as {:ok, value} or {:error, error}"
  @spec entity_ok!(any) :: {:ok, list(T.erp_entity()) | T.erp_entity()} | {:error, term}
  @spec entity_ok!(any, T.erp_options()) :: {:ok, list(T.erp_entity()) | T.erp_entity()} | {:error, term}
  def entity_ok!(obj, options \\ %{})
end # end defprotocol Noizu.ERP

#-------------------------------------------------------------------------------
# Useful default implementations
#-------------------------------------------------------------------------------
defimpl Noizu.ERP, for: List do
  def id(entities) do
    for obj <- entities do
      Noizu.ERP.id(obj)
    end
  end # end reference/1
  def id_ok(entities) do
    results = for obj <- entities do
      Noizu.ERP.id(obj)
    end |> Enum.filter(&(&1))
    length(results) == length(entities) && {:ok, results} || {:missing, results}
  end # end reference/1


  def ref(entities) do
    for obj <- entities do
      Noizu.ERP.ref(obj)
    end
  end # end reference/1
  def ref_ok(entities) do
    results = for obj <- entities do
                Noizu.ERP.ref(obj)
              end |> Enum.filter(&(&1))
    length(results) == length(entities) && {:ok, results} || {:missing, results}
  end # end reference/1

  def sref(entities) do
    for obj <- entities do
      Noizu.ERP.sref(obj)
    end
  end # end sref/1
  def sref_ok(entities) do
    results = for obj <- entities do
                Noizu.ERP.sref(obj)
              end |> Enum.filter(&(&1))
    length(results) == length(entities) && {:ok, results} || {:missing, results}
  end # end reference/1


  def record(entities, options \\ nil) do
    for obj <- entities do
      Noizu.ERP.record(obj, options)
    end
  end # end record/2

  def record!(entities, options \\ nil) do
    for obj <- entities do
      Noizu.ERP.record!(obj, options)
    end
  end # end record!/2

  def entity(entities, options \\ nil) do
    for obj <- entities do
      Noizu.ERP.entity(obj, options)
    end
  end # end entity/2
  def entity_ok(entities, options) do
    results = for obj <- entities do
                Noizu.ERP.entity(obj, options)
              end |> Enum.filter(&(&1))
    length(results) == length(entities) && {:ok, results} || {:missing, results}
  end # end reference/1

  def entity!(entities, options \\ nil) do
    for obj <- entities do
      Noizu.ERP.entity!(obj, options)
    end
  end # end entity!/2
  def entity_ok!(entities, options) do
    results = for obj <- entities do
                Noizu.ERP.entity!(obj, options)
              end |> Enum.filter(&(&1))
    length(results) == length(entities) && {:ok, results} || {:missing, results}
  end # end reference/1

end # end defimpl EntityReferenceProtocol, for: List

defimpl Noizu.ERP, for: Tuple do
  def id(obj) do
    case obj do
      {:ref, manager, identifier} when is_atom(manager)->
        #if function_exported?(manager, :sref, 1) do
          manager.id(identifier)
        #end
      {:ext_ref, manager, identifier} when is_atom(manager) ->
        manager.id(identifier)
    end
  end # end id/1
  def id_ok(obj) do
    result = id(obj)
    result && {:ok, result} || {:error, obj}
  end # end id/1


  def ref(obj) do
    case obj do
      {:ref, manager, _identifier} when is_atom(manager)-> obj
      {:ext_ref, manager, _identifier} when is_atom(manager) -> obj
    end
  end # end ref/1
  def ref_ok(obj) do
    result = ref(obj)
    result && {:ok, result} || {:error, obj}
  end # end ref/1


  def sref(obj) do
    case obj do
      {:ref, manager, identifier} when is_atom(manager)->
        #if function_exported?(manager, :sref, 1) do
          manager.sref(identifier)
        #end
      {:ext_ref, manager, identifier} when is_atom(manager) ->
        manager.sref(identifier)
    end
  end # end sref/1
  def sref_ok(obj) do
    result = sref(obj)
    result && {:ok, result} || {:error, obj}
  end # end sref/1


  def record(obj, options \\ nil) do
    case obj do
      {:ref, manager, identifier} when is_atom(manager)->
        #if function_exported?(manager, :entity, 2) do
          manager.record(identifier, options)
        #end
      {:ext_ref, manager, identifier} when is_atom(manager) ->
        manager.record(identifier, options)
    end
  end # end record/2

  def record!(obj, options \\ nil) do
    case obj do
      {:ref, manager, identifier} when is_atom(manager)->
        #if function_exported?(manager, :entity, 2) do
          manager.record!(identifier, options)
        #end
      {:ext_ref, manager, identifier} when is_atom(manager) ->
          manager.record!(identifier, options)
    end
  end # end record/2

  def entity(obj, options \\ nil) do
    case obj do
      {:ref, manager, _identifier} when is_atom(manager)->
        #if function_exported?(manager, :entity, 2) do
          manager.entity(obj, options)
        #end
      {:ext_ref, manager, _identifier} when is_atom(manager) ->

          manager.entity(obj, options)
    end
  end # end entity/2
  def entity_ok(obj, options) do
    result = entity(obj, options)
    result && {:ok, result} || {:error, obj}
  end # end entity_ok/1

  def entity!(obj, options \\ nil) do
    case obj do
      {:ref, manager, _identifier} when is_atom(manager)->
        #if function_exported?(manager, :entity, 2) do
        manager.entity!(obj, options)
        #end
      {:ext_ref, manager, _identifier} when is_atom(manager) ->
        manager.entity!(obj, options)
    end
  end # end entity/2
  def entity_ok!(obj, options) do
    result = entity!(obj, options)
    result && {:ok, result} || {:error, obj}
  end # end entity_ok/1
end # end defimpl EntityReferenceProtocol, for: Tuple

#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------
defprotocol Noizu.ERP do
  @fallback_to_any true
  #  Experimental, may remove after April 2023
  #
  #  @doc "Provider Resolver to provide ERP resolution"
  #  def __erp_dispatch__(ob)
  #
  #  @doc "Entity Supports ERP"
  #  def supported?(ob)
  
  @doc "Get underlying id for ref"
  def id(obj)
  @doc "Get underlying id for ref, return as {:ok, value} or {:error, error}"
  def id_ok(obj)

  @doc "Cast to noizu reference object"
  def ref(obj)
  @doc "Cast to noizu reference object, return as {:ok, value} or {:error, error}"
  def ref_ok(obj)

  @doc "Cast to noizu string reference object"
  def sref(obj)
  @doc "Cast to noizu string reference object, return as {:ok, value} or {:error, error}"
  def sref_ok(obj)

  @doc "Convert to persistence object. Options may be passed to coordinate actions like expanding embedded references."
  def record(obj, options \\ %{})

  @doc "Convert to persistence object Options may be passed to coordinate actions like expanding embedded references. (With transaction wrapper if required)"
  def record!(obj, options \\ %{})

  @doc "Convert to scaffolding.struct object. Options may be passed to coordinate actions like expanding embedded references."
  def entity(obj, options \\ %{})
  @doc "Convert to scaffolding.struct object. Options may be passed to coordinate actions like expanding embedded references, return as {:ok, value} or {:error, error}"
  def entity_ok(obj, options \\ %{})

  @doc "Convert to scaffolding.struct object Options may be passed to coordinate actions like expanding embedded references. (With transaction wrapper if required)"
  def entity!(obj, options \\ %{})
  @doc "Convert to scaffolding.struct object Options may be passed to coordinate actions like expanding embedded references. (With transaction wrapper if required), return as {:ok, value} or {:error, error}"
  def entity_ok!(obj, options \\ %{})


  def create(obj, context, options \\ %{})
  def create_ok(obj, context, options \\ %{})
  
  def create!(obj, context, options \\ %{})
  def create_ok!(obj, context, options \\ %{})

  def update(obj, context, options \\ %{})
  def update_ok(obj, context, options \\ %{})

  def update!(obj, context, options \\ %{})
  def update_ok!(obj, context, options \\ %{})

  
end # end defprotocol Noizu.ERP

#-------------------------------------------------------------------------------
# Useful default implementations
#-------------------------------------------------------------------------------
defimpl Noizu.ERP, for: List do
  def __erp_dispatch__(refs), do: {:ok, refs |> Enum.map(&(Noizu.ERP.__erp_dispatch__(&1)))}
  def supported?(_), do: true
  
  def id(refs), do: refs |> Enum.map(&(Noizu.ERP.id(&1)))
  def ref(refs), do: refs |> Enum.map(&(Noizu.ERP.ref(&1)))
  def sref(refs), do: refs |> Enum.map(&(Noizu.ERP.sref(&1)))
  def entity(refs), do: refs |> Enum.map(&(Noizu.ERP.entity(&1)))
  def entity(refs, options), do: refs |> Enum.map(&(Noizu.ERP.entity(&1, options)))
  def entity!(refs), do: refs |> Enum.map(&(Noizu.ERP.entity!(&1)))
  def entity!(refs, options), do: refs |> Enum.map(&(Noizu.ERP.entity!(&1, options)))
  def record(refs), do: refs |> Enum.map(&(Noizu.ERP.record(&1)))
  def record(refs, options), do: refs |> Enum.map(&(Noizu.ERP.record(&1, options)))
  def record!(refs), do: refs |> Enum.map(&(Noizu.ERP.record!(&1)))
  def record!(refs, options), do: refs |> Enum.map(&(Noizu.ERP.record!(&1, options)))
  def create(refs, context), do: refs |> Enum.map(&(Noizu.ERP.create(&1, context)))
  def create(refs, context, options), do: refs |> Enum.map(&(Noizu.ERP.create(&1, context, options)))
  def create!(refs, context), do: refs |> Enum.map(&(Noizu.ERP.create!(&1, context)))
  def create!(refs, context, options), do: refs |> Enum.map(&(Noizu.ERP.create!(&1, context, options)))
  def update(refs, context), do: refs |> Enum.map(&(Noizu.ERP.create(&1, context)))
  def update(refs, context, options), do: refs |> Enum.map(&(Noizu.ERP.create(&1, context, options)))
  def update!(refs, context), do: refs |> Enum.map(&(Noizu.ERP.create!(&1, context)))
  def update!(refs, context, options), do: refs |> Enum.map(&(Noizu.ERP.create!(&1, context, options)))




  def id_ok(refs) do
    {list, outcome} = Enum.map_reduce(refs, :ok, fn(ref, outcome) ->
      entry = Noizu.ERP.id_ok(ref)
      cond do
        elem(entry, 0) == :error -> {entry, :error}
        :else -> {entry, outcome}
      end
    end)
    {outcome, list}
  end
  def ref_ok(refs) do
    {list, outcome} = Enum.map_reduce(refs, :ok, fn(ref, outcome) ->
      entry = Noizu.ERP.ref_ok(ref)
      cond do
        elem(entry, 0) == :error -> {entry, :error}
        :else -> {entry, outcome}
      end
    end)
    {outcome, list}
  end
  def sref_ok(refs) do
    {list, outcome} = Enum.map_reduce(refs, :ok, fn(ref, outcome) ->
      entry = Noizu.ERP.sref_ok(ref)
      cond do
        elem(entry, 0) == :error -> {entry, :error}
        :else -> {entry, outcome}
      end
    end)
    {outcome, list}
  end


  def entity_ok(refs) do
    {list, outcome} = Enum.map_reduce(refs, :ok, fn(ref, outcome) ->
      entry = Noizu.ERP.entity_ok(ref)
      cond do
        elem(entry, 0) == :error -> {entry, :error}
        :else -> {entry, outcome}
      end
    end)
    {outcome, list}
  end
  def entity_ok(refs, options) do
    {list, outcome} = Enum.map_reduce(refs, :ok, fn(ref, outcome) ->
      entry = Noizu.ERP.entity_ok(ref, options)
      cond do
        elem(entry, 0) == :error -> {entry, :error}
        :else -> {entry, outcome}
      end
    end)
    {outcome, list}
  end

  def entity_ok!(refs) do
    {list, outcome} = Enum.map_reduce(refs, :ok, fn(ref, outcome) ->
      entry = Noizu.ERP.entity_ok!(ref)
      cond do
        elem(entry, 0) == :error -> {entry, :error}
        :else -> {entry, outcome}
      end
    end)
    {outcome, list}
  end
  def entity_ok!(refs, options) do
    {list, outcome} = Enum.map_reduce(refs, :ok, fn(ref, outcome) ->
      entry = Noizu.ERP.entity_ok!(ref, options)
      cond do
        elem(entry, 0) == :error -> {entry, :error}
        :else -> {entry, outcome}
      end
    end)
    {outcome, list}
  end


  def create_ok(refs, context) do
    {list, outcome} = Enum.map_reduce(refs, :ok, fn(ref, outcome) ->
      entry = Noizu.ERP.create_ok(ref, context)
      cond do
        elem(entry, 0) == :error -> {entry, :error}
        :else -> {entry, outcome}
      end
    end)
    {outcome, list}
  end
  def create_ok(refs, context, options) do
    {list, outcome} = Enum.map_reduce(refs, :ok, fn(ref, outcome) ->
      entry = Noizu.ERP.create_ok(ref, context, options)
      cond do
        elem(entry, 0) == :error -> {entry, :error}
        :else -> {entry, outcome}
      end
    end)
    {outcome, list}
  end

  def create_ok!(refs, context) do
    {list, outcome} = Enum.map_reduce(refs, :ok, fn(ref, outcome) ->
      entry = Noizu.ERP.create_ok!(ref, context)
      cond do
        elem(entry, 0) == :error -> {entry, :error}
        :else -> {entry, outcome}
      end
    end)
    {outcome, list}
  end
  def create_ok!(refs, context, options) do
    {list, outcome} = Enum.map_reduce(refs, :ok, fn(ref, outcome) ->
      entry = Noizu.ERP.create_ok!(ref, context, options)
      cond do
        elem(entry, 0) == :error -> {entry, :error}
        :else -> {entry, outcome}
      end
    end)
    {outcome, list}
  end


  def update_ok(refs, context) do
    {list, outcome} = Enum.map_reduce(refs, :ok, fn(ref, outcome) ->
      entry = Noizu.ERP.update_ok(ref, context)
      cond do
        elem(entry, 0) == :error -> {entry, :error}
        :else -> {entry, outcome}
      end
    end)
    {outcome, list}
  end
  def update_ok(refs, context, options) do
    {list, outcome} = Enum.map_reduce(refs, :ok, fn(ref, outcome) ->
      entry = Noizu.ERP.update_ok(ref, context, options)
      cond do
        elem(entry, 0) == :error -> {entry, :error}
        :else -> {entry, outcome}
      end
    end)
    {outcome, list}
  end

  def update_ok!(refs, context) do
    {list, outcome} = Enum.map_reduce(refs, :ok, fn(ref, outcome) ->
      entry = Noizu.ERP.update_ok!(ref, context)
      cond do
        elem(entry, 0) == :error -> {entry, :error}
        :else -> {entry, outcome}
      end
    end)
    {outcome, list}
  end
  def update_ok!(refs, context, options) do
    {list, outcome} = Enum.map_reduce(refs, :ok, fn(ref, outcome) ->
      entry = Noizu.ERP.update_ok!(ref, context, options)
      cond do
        elem(entry, 0) == :error -> {entry, :error}
        :else -> {entry, outcome}
      end
    end)
    {outcome, list}
  end
end # end defimpl EntityReferenceProtocol, for: List

defimpl Noizu.ERP, for: Tuple do
  defmacrop invalid_ref(ref) do
    quote do
      {:error, {:ref, {:invalid, unquote(ref)}}}
    end
  end

  defmacrop invalid_ref_error(ref) do
    quote do
      {:ref, {:invalid, unquote(ref)}}
    end
  end
#  Experimental, may remove after April 2023
#  def __erp_dispatch__({r, m, _}) when r in [:ref, :ext_ref], do: {:ok, m}
#  def __erp_dispatch__(ref), do: invalid_ref(ref)
#
#  def supported?(ref) do
#    case elem(ref, 0) do
#      :ref -> true
#      :ext_ref -> true
#      _ -> false
#    end
#  end
  
  def id_ok({r, m, _} = ref) when r in [:ref, :ext_ref], do: apply(m, :id_ok, [ref])
  def id_ok(ref), do: invalid_ref(ref)

  def ref_ok({r, m, _} = ref) when r in [:ref, :ext_ref], do: apply(m, :ref_ok, [ref])
  def ref_ok(ref), do: invalid_ref(ref)

  def sref_ok({r, m, _} = ref) when r in [:ref, :ext_ref], do: apply(m, :sref_ok, [ref])
  def sref_ok(ref), do: invalid_ref(ref)

  def entity_ok({r, m, _} = ref) when r in [:ref, :ext_ref], do: apply(m, :entity_ok, [ref])
  def entity_ok(ref), do: invalid_ref(ref)
  def entity_ok({r, m, _} = ref, options) when r in [:ref, :ext_ref], do: apply(m, :entity_ok, [ref, options])
  def entity_ok(ref, _), do: invalid_ref(ref)
  
  def entity_ok!({r, m, _} = ref) when r in [:ref, :ext_ref], do: apply(m, :entity_ok!, [ref])
  def entity_ok!(ref), do: invalid_ref(ref)
  def entity_ok!({r, m, _} = ref, options) when r in [:ref, :ext_ref], do: apply(m, :entity_ok!, [ref, options])
  def entity_ok!(ref, _), do: invalid_ref(ref)

  def create_ok({r, m, _} = ref, context) when r in [:ref, :ext_ref], do: apply(m, :create_ok, [ref, context])
  def create_ok(ref, _), do: invalid_ref(ref)
  def create_ok({r, m, _} = ref, context, options) when r in [:ref, :ext_ref], do: apply(m, :create_ok, [ref, context, options])
  def create_ok(ref, _, _), do: invalid_ref(ref)
  
  def create_ok!({r, m, _} = ref, context) when r in [:ref, :ext_ref], do: apply(m, :create_ok!, [ref, context])
  def create_ok!(ref, _), do: invalid_ref(ref)
  def create_ok!({r, m, _} = ref, context, options) when r in [:ref, :ext_ref], do: apply(m, :create_ok!, [ref, context, options])
  def create_ok!(ref, _, _), do: invalid_ref(ref)


  def update_ok({r, m, _} = ref, context) when r in [:ref, :ext_ref], do: apply(m, :update_ok, [ref, context])
  def update_ok(ref, _), do: invalid_ref(ref)
  def update_ok({r, m, _} = ref, context, options) when r in [:ref, :ext_ref], do: apply(m, :update_ok, [ref, context, options])
  def update_ok(ref, _, _), do: invalid_ref(ref)

  def update_ok!({r, m, _} = ref, context) when r in [:ref, :ext_ref], do: apply(m, :update_ok!, [ref, context])
  def update_ok!(ref, _), do: invalid_ref(ref)
  def update_ok!({r, m, _} = ref, context, options) when r in [:ref, :ext_ref], do: apply(m, :update_ok!, [ref, context, options])
  def update_ok!(ref, _, _), do: invalid_ref(ref)


  def id({r, m, _} = ref) when r in [:ref, :ext_ref], do: apply(m, :id, [ref])
  def id(ref), do: (raise Noizu.ERP.Exception, ref: ref, detail: invalid_ref_error(ref))

  def ref({r, m, _} = ref) when r in [:ref, :ext_ref], do: apply(m, :ref, [ref])
  def ref(ref), do: (raise Noizu.ERP.Exception, ref: ref, detail: invalid_ref_error(ref))

  def sref({r, m, _} = ref) when r in [:ref, :ext_ref], do: apply(m, :sref, [ref])
  def sref(ref), do: (raise Noizu.ERP.Exception, ref: ref, detail: invalid_ref_error(ref))


  def record({r, m, _} = ref) when r in [:ref, :ext_ref], do: apply(m, :record, [ref])
  def record(ref), do: (raise Noizu.ERP.Exception, ref: ref, detail: invalid_ref_error(ref))
  def record({r, m, _} = ref, options) when r in [:ref, :ext_ref], do: apply(m, :record, [ref, options])
  def record(ref, _), do: (raise Noizu.ERP.Exception, ref: ref, detail: invalid_ref_error(ref))

  def record!({r, m, _} = ref) when r in [:ref, :ext_ref], do: apply(m, :record!, [ref])
  def record!(ref), do: (raise Noizu.ERP.Exception, ref: ref, detail: invalid_ref_error(ref))
  def record!({r, m, _} = ref, options) when r in [:ref, :ext_ref], do: apply(m, :record!, [ref, options])
  def record!(ref, _), do: (raise Noizu.ERP.Exception, ref: ref, detail: invalid_ref_error(ref))
  
  def entity({r, m, _} = ref) when r in [:ref, :ext_ref], do: apply(m, :entity, [ref])
  def entity(ref), do: (raise Noizu.ERP.Exception, ref: ref, detail: invalid_ref_error(ref))
  def entity({r, m, _} = ref, options) when r in [:ref, :ext_ref], do: apply(m, :entity, [ref, options])
  def entity(ref, _), do: (raise Noizu.ERP.Exception, ref: ref, detail: invalid_ref_error(ref))

  def entity!({r, m, _} = ref) when r in [:ref, :ext_ref], do: apply(m, :entity!, [ref])
  def entity!(ref), do: (raise Noizu.ERP.Exception, ref: ref, detail: invalid_ref_error(ref))
  def entity!({r, m, _} = ref, options) when r in [:ref, :ext_ref], do: apply(m, :entity!, [ref, options])
  def entity!(ref, _), do: (raise Noizu.ERP.Exception, ref: ref, detail: invalid_ref_error(ref))

  def create(ref, _, _ \\ nil), do: (raise Noizu.ERP.Exception, ref: ref, detail: {:create, {:unsupported, ref}})
  def create!(ref, _, _ \\ nil), do: (raise Noizu.ERP.Exception, ref: ref, detail: {:create!, {:unsupported, ref}})
  def update(ref, _, _ \\ nil), do: (raise Noizu.ERP.Exception, ref: ref, detail: {:update, {:unsupported, ref}})
  def update!(ref, _, _ \\ nil), do: (raise Noizu.ERP.Exception, ref: ref, detail: {:update!, {:unsupported, ref}})
end # end defimpl EntityReferenceProtocol, for: Tuple

defimpl Noizu.ERP, for: [Any] do
  
  def id_ok(ref), do: {:error, {:erp, {:unsupported, ref}}}
  def ref_ok(ref), do: {:error, {:erp, {:unsupported, ref}}}
  def sref_ok(ref), do: {:error, {:erp, {:unsupported, ref}}}
  
  def entity_ok(ref), do: {:error, {:erp, {:unsupported, ref}}}
  def entity_ok(ref, _), do: {:error, {:erp, {:unsupported, ref}}}
  def entity_ok!(ref), do: {:error, {:erp, {:unsupported, ref}}}
  def entity_ok!(ref, _), do: {:error, {:erp, {:unsupported, ref}}}
  
  def create_ok(ref, _), do: {:error, {:erp, {:unsupported, ref}}}
  def create_ok(ref, _, _), do: {:error, {:erp, {:unsupported, ref}}}
  def create_ok!(ref, _), do: {:error, {:erp, {:unsupported, ref}}}
  def create_ok!(ref, _, _), do: {:error, {:erp, {:unsupported, ref}}}
  
  def update_ok(ref, _), do: {:error, {:erp, {:unsupported, ref}}}
  def update_ok(ref, _, _), do: {:error, {:erp, {:unsupported, ref}}}
  def update_ok!(ref, _), do: {:error, {:erp, {:unsupported, ref}}}
  def update_ok!(ref, _, _), do: {:error, {:erp, {:unsupported, ref}}}
  
  
  def id(_), do: nil
  
  def ref(_), do: nil
  
  def sref(_), do: nil
  
  def entity(_), do: nil
  def entity(_, _), do: nil
  def entity!(_), do: nil
  def entity!(_, _), do: nil
  
  def record(_), do: nil
  def record(_, _), do: nil
  def record!(_), do: nil
  def record!(_, _), do: nil
  
  def create(ref, _), do: (raise Noizu.ERP.Exception, ref: ref, detail: :unsupported, message: "ref must derive or implement Noizu.ERP to call this method")
  def create(ref, _, _), do: (raise Noizu.ERP.Exception, ref: ref, detail: :unsupported, message: "ref must derive or implement Noizu.ERP to call this method")
  def create!(ref, _), do: (raise Noizu.ERP.Exception, ref: ref, detail: :unsupported, message: "ref must derive or implement Noizu.ERP to call this method")
  def create!(ref, _, _), do: (raise Noizu.ERP.Exception, ref: ref, detail: :unsupported, message: "ref must derive or implement Noizu.ERP to call this method")
  
  def update(ref, _), do: (raise Noizu.ERP.Exception, ref: ref, detail: :unsupported, message: "ref must derive or implement Noizu.ERP to call this method")
  def update(ref, _, _), do: (raise Noizu.ERP.Exception, ref: ref, detail: :unsupported, message: "ref must derive or implement Noizu.ERP to call this method")
  def update!(ref, _), do: (raise Noizu.ERP.Exception, ref: ref, detail: :unsupported, message: "ref must derive or implement Noizu.ERP to call this method")
  def update!(ref, _, _), do: (raise Noizu.ERP.Exception, ref: ref, detail: :unsupported, message: "ref must derive or implement Noizu.ERP to call this method")
  
  defmacro __deriving__(module, _, _) do
    derive(module)
  end

  def derive(module) do
    quote bind_quoted: [module: module] do
      defimpl Noizu.Entity.Protocol, for: [module] do
    
        def id_ok(ref), do: apply(module, :id_ok, [ref])
        def ref_ok(ref), do: apply(module, :ref_ok, [ref])
        def sref_ok(ref), do: apply(module, :sref_ok, [ref])
    
        def entity_ok(ref), do: apply(module, :entity_ok, [ref])
        def entity_ok(ref, options), do: apply(module, :entity_ok, [ref, options])
        def entity_ok!(ref), do: apply(module, :entity_ok, [ref])
        def entity_ok!(ref, options), do: apply(module, :entity_ok, [ref, options])
    
        def create_ok(ref, context), do: apply(module, :create_ok, [ref, context])
        def create_ok(ref, context, options), do: apply(module, :create_ok, [ref, context, options])
        def create_ok!(ref, context), do: apply(module, :create_ok, [ref, context])
        def create_ok!(ref, context, options), do: apply(module, :create_ok, [ref, context, options])
    
        def update_ok(ref, context), do: apply(module, :update_ok, [ref, context])
        def update_ok(ref, context, options), do: apply(module, :update_ok, [ref, context, options])
        def update_ok!(ref, context), do: apply(module, :update_ok, [ref, context])
        def update_ok!(ref, context, options), do: apply(module, :update_ok, [ref, context, options])
    
    
        def id(ref), do: apply(module, :id, [ref])
    
        def ref(ref), do: apply(module, :ref, [ref])
    
        def sref(ref), do: apply(module, :sref, [ref])
    
        def entity(ref), do: apply(module, :entity, [ref])
        def entity(ref, options), do: apply(module, :entity, [ref, options])
        def entity!(ref), do: apply(module, :entity!, [ref])
        def entity!(ref, options), do: apply(module, :entity!, [ref, options])
    
        def record(ref), do: apply(module, :record, [ref])
        def record(ref, options), do: apply(module, :record, [ref, options])
        def record!(ref), do: apply(module, :record!, [ref])
        def record!(ref, options), do: apply(module, :record!, [ref, options])
    
        def create(ref, context), do: apply(module, :create, [ref, context])
        def create(ref, context, options), do: apply(module, :create, [ref, context, options])
        def create!(ref, context), do: apply(module, :create!, [ref, context])
        def create!(ref, context, options), do: apply(module, :create!, [ref, context, options])
    
        def update(ref, context), do: apply(module, :update, [ref, context])
        def update(ref, context, options), do: apply(module, :update, [ref, context, options])
        def update!(ref, context), do: apply(module, :update!, [ref, context])
        def update!(ref, context, options), do: apply(module, :update!, [ref, context, options])
      end
    end
  end
end
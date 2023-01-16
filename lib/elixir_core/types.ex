defmodule Noizu.Types do
  
  @type erp_options :: list | Map.t
  
  @typedoc "Entity identifier type, usually integer | atom, but may be a ref tuple or other."
  @type erp_id() :: erp_id(term())
  @type erp_id(r_identifier_type) :: r_identifier_type

  @typedoc "Entity reference type"
  @type erp_ref() :: erp_ref(module(), erp_id())
  @type erp_ref(r_entity_type) :: erp_ref(r_entity_type, erp_id())
  @type erp_ref(r_entity_type, r_identifier_type) :: {:ref, r_entity_type, r_identifier_type}
  
  @typedoc """
    Serialized entity reference type.
    ## Example
    "ref.noizu-caller.system"
    "ref.cms.{4.2.3-3}"
    "ref.user.134"
  """
  @type erp_sref :: String.t

  @typedoc """
  Noizu.ERP protocol compliant entity type
  """
  @type erp_entity() :: erp_entity(module())
  @type erp_entity(r_entity_type) :: %{:__struct__ => r_entity_type, optional(atom()) => any}
  
  @typedoc """
  Noizu.ERP handle (ref, sref or entity)
  """
  @type erp_handle() :: erp_handle(module())
  @type erp_handle(r_entity_type) :: erp_ref(r_entity_type) | erp_entity(r_entity_type) | erp_sref()

  @typedoc """
  Noizu.ERP protocol ref, entity, sref or identifier
  """
  @type entity_reference() :: entity_reference(module())
  @type entity_reference(r_entity_type) :: entity_reference(r_entity_type, term)
  @type entity_reference(r_entity_type, r_identifier_type) :: erp_handle(r_entity_type) | erp_id(r_identifier_type)
end
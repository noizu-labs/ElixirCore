#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2023 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.ERP.Serializer.Behaviour do
  @type options :: Map.t | term | nil
  @type context :: term
  @type ref :: {:ref, module, term}
  @type response_tuple(type) :: {:ok, type} | {:error, term}
  
  @callback __string_to_id__(module, String.t) :: response_tuple(term)
  @callback __id_to_string__(module, term) :: response_tuple(String.t)
  @callback __valid_identifier__(module, term) :: :ok | {:error, term}
  @callback __sref_module__(module) :: response_tuple(String.t)
  @callback __sref_config__(module) :: response_tuple(any)
  
  require Record
  Record.defrecord(:erp_serializer_config, [provider: nil, module: nil, handle: nil, settings: nil, constraints: nil])
  @type erp_serializer_config :: record(:erp_serializer_config, provider: module, module: module, handle: String.t, settings: nil, constraints: list)
  
  
end
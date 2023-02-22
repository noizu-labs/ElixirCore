#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2023 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------


defmodule Noizu.ERP.Dispatcher.Behaviour do
  @type options :: Map.t | term | nil
  @type context :: term
  @type ref :: {:ref, module, term}
  @type response_tuple(type) :: {:ok, type} | {:error, term}
  
  @callback id_ok(module, term) :: response_tuple(any)
  @callback ref_ok(module, term) :: response_tuple(ref)
  @callback sref_ok(module, term) :: response_tuple(String.t)
  @callback entity_ok(module, term, options) :: response_tuple(struct)
  @callback entity_ok!(module, term, options) :: response_tuple(struct)
  
  @callback id(module, term) :: any | nil
  @callback ref(module, term) :: ref | nil
  @callback sref(module, term) :: String.t | nil
  @callback entity(module, term, options) :: struct
  @callback entity!(module, term, options) :: struct

end
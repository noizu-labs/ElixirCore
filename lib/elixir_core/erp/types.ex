#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2023 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.ERP.Types do
  
  #=======================================
  # Records
  #=======================================
  
  require Record
  Record.defrecord(:ref,
    entity: nil,
    identifier: nil,
  )
  @type ref :: record(:ref, entity: atom, identifier: any)
  
  Record.defrecord(:ext_ref,
    entity: nil,
    identifier: nil,
  )
  @type ext_ref :: record(:ext_ref, entity: atom, identifier: any)
  
end
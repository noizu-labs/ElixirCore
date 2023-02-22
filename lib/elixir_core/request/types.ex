#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2023 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule  Noizu.ElixirCore.RequestContext.Types do
  #=======================================
  # Records
  #=======================================

  require Record
  
  Record.defrecord(:request_authorization, Noizu.Request.ExtendedContext,
    roles: nil,
    permissions: nil,
    meta: nil
  )
  
  Record.defrecord(:extended_request_context, Noizu.Request.ExtendedContext,
    time: nil,
    token: nil,
    reason: nil,
    options: nil,
    meta: nil
  )
  
  Record.defrecord(:request_context, Noizu.Request.Context,
    __status__: :loaded,
    caller: nil,
    auth: nil,
    manager: nil,
    extended: nil,
    inner_context: nil
  )
  
end
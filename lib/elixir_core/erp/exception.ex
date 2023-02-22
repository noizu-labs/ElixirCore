#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2023 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.ERP.Exception do
  defexception [ref: nil, detail: :operation_failed, message: "Operation Failed"]
end
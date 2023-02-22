#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2023 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.PermissionException do
  defexception message: "Access Denied",
               permission: nil,
               resource: nil,
               term: nil
  
  def to_term(e), do: {:error, e}
end
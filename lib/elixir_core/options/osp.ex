#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defprotocol Noizu.ElixirCore.OSP do
  @doc """
  Extract an option from user provided values
  """
  def extract(this, acc)
end # end defprotocol Noizu.ERP

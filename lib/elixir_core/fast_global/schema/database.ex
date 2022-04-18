#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

use Amnesia

defdatabase Noizu.FastGlobal.Database do
  #-----------------------------------------------------------------------------
  # @Settings
  #-----------------------------------------------------------------------------
  deftable Settings, [:identifier, :value], type: :set, index: [] do
    @type t :: %Settings{
                 identifier: any,
                 value: any
               }

  end # end deftable Email.Templates
end
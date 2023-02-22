#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2023 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.ContextException do
  defexception message: "Context Exception",
               term: :other
  def to_term(e), do: {:error, e}
  
  def escape() do
    raise Noizu.ContextException, term: :escape
  end
  def escape(term) do
    raise Noizu.ContextException, term: term
  end
end

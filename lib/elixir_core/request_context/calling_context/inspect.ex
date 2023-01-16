#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2023 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

if Application.get_env(:noizu_core, :inspect_calling_context, true) do
  #-----------------------------------------------------------------------------
  # Inspect Protocol
  #-----------------------------------------------------------------------------
  defimpl Inspect, for: Noizu.ElixirCore.CallingContext do
    import Inspect.Algebra
    def inspect(entity, opts) do
      heading = "#Context(#{entity.token})"
      {separator, end_separator} = if opts.pretty, do: {"\n   ", "\n"}, else: {" ", " "}
      caller = (with {:ok, sref} <- Noizu.ERP.sref_ok(entity.caller) do
                  sref
                else
                  _ -> "#{inspect entity.caller}"
                end)
      inner = cond do
                opts.limit == :infinity ->
                  concat(["<#{separator}", to_doc(Map.from_struct(entity), opts), "#{separator}>"])
                opts.limit >= 200 ->
                  concat ["<",
                    "#{separator}caller: #{caller},",
                    "#{separator}reason: #{inspect entity.reason},",
                    "#{separator}permissions: #{inspect entity.auth[:permissions]}",
                    "#{end_separator}>"]
                opts.limit >= 150 ->
                  concat ["<",
                    "#{separator}caller: #{caller},",
                    "#{separator}reason: #{inspect entity.reason}",
                    "#{end_separator}>"]
                opts.limit >= 100 ->
                  concat ["<",
                    "#{separator}caller: #{caller}",
                    "#{end_separator}>"]
                true -> "<>"
              end
      concat [heading, inner]
    end # end inspect/2
  end # end defimpl
end

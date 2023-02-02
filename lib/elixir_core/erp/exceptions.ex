defmodule Noizu.ERP.Exception do
  defexception [:ref, detail: :operation_failed, message: "Operation Failed"]
end

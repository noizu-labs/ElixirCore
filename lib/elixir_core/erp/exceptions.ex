defmodule Noizu.ERP.Exception do
  defexception [ref: nil, detail: :operation_failed, message: "Operation Failed"]
end
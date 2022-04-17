#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.Mixfile do
  use Mix.Project

  def project do
    [app: :noizu_core,
     version: "1.0.15",
     elixir: "~> 1.13.1",
     package: package(),
     deps: deps(),
     description: "Request Context Helper",
     docs: docs()
   ]
  end

  defp package do
    [
      maintainers: ["noizu"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/noizu/ElixirCore"}
    ]
  end

  def application do
    [ applications: [:logger, :crypto] ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.28.3", only: [:dev, :test], optional: true, runtime: false}, # Documentation Provider
      {:markdown, github: "devinus/markdown", only: [:dev], optional: true}, # Markdown processor for ex_doc
      {:elixir_uuid, "~> 1.2", only: :test, optional: true}
    ]
  end

  defp docs do
    [
      source_url_pattern: "https://github.com/noizu/ElixirCore/blob/master/%{path}#L%{line}",
      extras: ["README.md", "markdown/config.md"]
    ]
  end

end

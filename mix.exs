#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.Mixfile do
  use Mix.Project

  def project do
    [app: :noizu_core,
     version: "1.0.17",
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
      {:fastglobal, "~> 1.0"}, # https://github.com/discordapp/fastglobal
      {:semaphore, "~> 1.0"}, # https://github.com/discordapp/semaphore
      {:noizu_mnesia_versioning, github: "noizu/MnesiaVersioning", tag: "0.1.10"},
      {:amnesia, git: "https://github.com/noizu/amnesia.git", ref: "9266002", optional: true}, # Mnesia Wrapper
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

defmodule Rogger.Mixfile do
  use Mix.Project

  def project do
    [app: :rogger,
     version: "0.0.5",
     elixir: "~> 1.0",
     description: description,
     package: package,
     source_url: "https://github.com/duartejc/rogger",
     deps: deps,
     docs: [readme: "README.md", main: "README"]]
  end

  def application do
    [applications: [:logger, :amqp]]
  end

  defp deps do
    [{:amqp, "0.1.1"},
     {:timex, "~> 0.13.4"},
     {:inch_ex, only: :docs}]
  end

  defp description do
    """
    Elixir logger to publish log messages in RabbitMQ.
    """
  end

  defp package do
    [files: ["lib", "mix.exs", "README.md", "LICENSE"],
     contributors: ["Jean Duarte"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/duartejc/rogger"}]
  end
end

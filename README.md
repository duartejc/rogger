Rogger
======

[![Hex Version](http://img.shields.io/hexpm/v/rogger.svg)](https://hex.pm/packages/rogger)

Simple Elixir logger which publishes messages in RabbitMQ

## Usage

Add Rogger as a dependency in your mix.exs file.

```elixir
def deps do
  [{:rogger, "~> 0.0.3"}]
end
```

Include :rogger in your application list:

```elixir
def application do
  [applications: [:rogger]]
end
```

Add configuration related to your RabbitMQ instance:

```elixir
config :rogger,
    host: "localhost",
    username: "guest",
    password: "guest"
```

Start Rogger process using **Rogger.start_link([])** anywhere in your application or register it as a supervised process.

Then, run **mix deps.get** to fetch and compile Rogger.

Publish your logs :

```elixir
Rogger.info "Some info message"

Rogger.warn "Some warning message"

Rogger.error "Some error message"
```

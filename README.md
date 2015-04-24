Rogger
======

Simple Elixir logger which publishes messages in RabbitMQ

## Usage

Add Rogger as a dependency in your mix.exs file.

    def deps do
      [{:rogger, git: "git://github.com/duartejc/rogger.git"}]
    end

Include :rogger in your application list:

    def application do
      [applications: [:rogger]]
    end

Add configuration related to your RabbitMQ instance:

    config :rogger,
        host: "localhost",
        username: "guest",
        password: "guest"

Start Rogger process using **Rogger.start_link([])** anywhere in your application or register it as a supervised process.

Then, run **mix deps.get** to fetch and compile Rogger.

Publish your logs :

    Rogger.info "Some info message"

    Rogger.warn "Some warning message"

    Rogger.error "Some error message"

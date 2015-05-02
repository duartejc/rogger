defmodule Rogger do
  use Application
  use GenServer
  use Timex
  require Logger

  @info_exchange  "info"
  @warn_exchange  "warn"
  @error_exchange "error"
  @app Application.get_env :rogger, :app

  ### Public API
  def start_link(opts) do
    Logger.info "Initializing Rogger..."
    {:ok, conn} = open_connection
    {:ok, chan} = open_channel conn
    declare_exchange chan, @info_exchange
    declare_exchange chan, @warn_exchange
    declare_exchange chan, @error_exchange
    GenServer.start_link(Rogger, chan, name: :rogger)
  end

  def info(message, routing_key \\ "") do
    GenServer.cast(:rogger, {:info, routing_key, ~s("#{message}")})
  end

  def warn(message, routing_key \\ "") do
    GenServer.cast(:rogger, {:warn, routing_key, ~s("#{message}")})
  end

  def error(message, routing_key \\ "") do
    GenServer.cast(:rogger, {:error, routing_key, ~s("#{message}")})
  end

  ### Server API
  def open_connection do
    env = Application.get_all_env(:rogger)
    connection_url = "amqp://#{env[:username]}:#{env[:password]}@#{env[:host]}"
    conn = AMQP.Connection.open(connection_url)

    case conn do
      {:ok, pid} ->
        {:ok, pid}
      {:error, :ehostunreach} ->
        Logger.error "Could not connect to #{env[:host]}. Host unreached."
        {:error}
      {:error, {:auth_failure, 'Disconnected'}} ->
        Logger.error "Could not connect to #{env[:host]}. Authentication failure."
        {:error}
    end
  end

  def open_channel(conn) do
    AMQP.Channel.open(conn)
  end

  def declare_queue(chan, queue) do
    {:ok, info} = AMQP.Queue.declare chan, queue
    {:ok}
  end

  def declare_exchange(chan, exchange) do
    AMQP.Exchange.declare chan, exchange
    {:ok}
  end

  def bind(chan, queue, exchange) do
    AMQP.Queue.bind chan, queue, exchange
    {:ok}
  end

  def publish(chan, exchange, routing_key, message, opts) do
    AMQP.Basic.publish chan, exchange, routing_key, message, opts
    {:ok}
  end

  def handle_cast({:info, routing_key, message}, channel) do
    timestamp = Date.local |> Date.convert(:secs)
    publish channel, @info_exchange, routing_key, message, [app_id: @app, timestamp: timestamp]
    {:noreply, channel}
  end

  def handle_cast({:warn, routing_key, message}, channel) do
    timestamp = Date.local |> Date.convert(:secs)
    publish channel, @warn_exchange, routing_key, message, [app_id: @app, timestamp: timestamp]
    {:noreply, channel}
  end

  def handle_cast({:error, routing_key, message}, channel) do
    timestamp = Date.local |> Date.convert(:secs)
    publish channel, @error_exchange, routing_key, message, [app_id: @app, timestamp: timestamp]
    {:noreply, channel}
  end
end

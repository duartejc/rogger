defmodule Rogger do
  use Application
  use GenServer
  require Logger

  @info_exchange  "info"
  @warn_exchange  "warn"
  @error_exchange "error"

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

  def info(message) do
    GenServer.cast(:rogger, {:info, message})
  end

  def warn(message) do
    GenServer.cast(:rogger, {:warn, message})
  end

  def error(message) do
    GenServer.cast(:rogger, {:error, message})
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

  def publish(chan, exchange, message) do
    AMQP.Basic.publish chan, exchange, "", message
    {:ok}
  end

  def handle_cast({:info, message}, channel) do
    publish channel, @info_exchange, message
    {:noreply, channel}
  end

  def handle_cast({:warn, message}, channel) do
    publish channel, @warn_exchange, message
    {:noreply, channel}
  end

  def handle_cast({:error, message}, channel) do
    publish channel, @error_exchange, message
    {:noreply, channel}
  end
end

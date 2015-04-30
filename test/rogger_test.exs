defmodule RoggerTest do
  use ExUnit.Case

  test "it can read 'host' property" do
    prop = Application.get_env(:rogger, :host)
    assert "localhost" = prop
  end

  test "it can connect to rabbit using configurations" do
    status = Rogger.open_connection
    assert {:ok, conn} = status
  end

  test "it creates a channel using a connection" do
    {:ok, conn} = AMQP.Connection.open
    status = Rogger.open_channel(conn)
    assert {:ok, chan} = status
  end

  test "it creates a queue using a channel" do
    {:ok, conn} = AMQP.Connection.open
    {:ok, chan} = AMQP.Channel.open(conn)
    status = Rogger.declare_queue(chan, "test_queue")
    assert {:ok} = status
  end

  test "it declares an exchange using a channel" do
    {:ok, conn} = AMQP.Connection.open
    {:ok, chan} = AMQP.Channel.open(conn)
    status = Rogger.declare_exchange(chan, "test_exchange")
    assert {:ok} = status
  end

  test "it binds an exchange to a queue using a channel" do
    {:ok, conn} = AMQP.Connection.open
    {:ok, chan} = AMQP.Channel.open(conn)
    status = Rogger.bind(chan, "test_queue", "test_exchange")
    assert {:ok} = status
  end

  test "it publishes a message to a queue using a channel" do
    {:ok, conn} = AMQP.Connection.open
    {:ok, chan} = AMQP.Channel.open(conn)
    status = Rogger.publish(chan, "test_exchange", "test_routing_key", "Hello, World!", [timestamp: :os.timestamp])
    assert {:ok} = status
  end

end

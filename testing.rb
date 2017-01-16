require 'socket'
require_relative 'client'

Thread.new do
	client = GameClient.new("Bob", '0.0.0.0', 8080)
	client.run
end

Thread.new do
	client = GameClient.new("Jeff", '0.0.0.0', 8080)
	client.run
end

Thread.new do
	client = GameClient.new("Matt", '0.0.0.0', 8080)
	client.run
end

Thread.new do
	client = GameClient.new("Brad", '0.0.0.0', 8080)
	client.run
end


Thread.new do
	client = GameClient.new("Jack", '0.0.0.0', 8080)
	client.run
end

Thread.new do
	client = GameClient.new("David", '0.0.0.0', 8080)
	client.run
end

Thread.new do
	client = GameClient.new("Klein", '0.0.0.0', 8080)
	client.run
end

Thread.new do
	client = GameClient.new("Neal", '0.0.0.0', 8080)
	client.run
end

Thread.new do
	client = GameClient.new("George", '0.0.0.0', 8080)
	client.run
end


Thread.new do
	client = GameClient.new("Wharton", '0.0.0.0', 8080)
	client.run
end

Thread.new do
	client = GameClient.new("Larry", '0.0.0.0', 8080)
	client.run
end

Thread.new do
	client = GameClient.new("Rochester", '0.0.0.0', 8080)
	client.run
end

Thread.new do
	client = GameClient.new("Harry", '0.0.0.0', 8080)
	client.run
end

Thread.new do
	client = GameClient.new("Crosby", '0.0.0.0', 8080)
	client.run
end


client = GameClient.new("Thomas", '0.0.0.0', 8080)
client.run
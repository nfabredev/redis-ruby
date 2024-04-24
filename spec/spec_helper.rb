# require 'rspec'
require_relative "../app/server.rb"

# start our server
Thread.new do
    RedisServer.new(6380).listen()
end

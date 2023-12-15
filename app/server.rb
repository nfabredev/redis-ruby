# frozen_string_literal: true

require 'socket'
require 'singleton'

class Storage
  include Singleton

  def initialize
    @store = {}
  end

  def set_value(key, value)
    @store[key] = value
  end

  def get_value(key)
    @store[key]
  end
end

class Parser
  SKIPPED_STRING_DESCRIPTOR = /[*$]\d+/

  def initialize(message)
    @message = message
    @response = ''
  end

  def parse
    puts "Message to parse - #{@message}"
    commands = @message.split("\r\n").reject { |element| (element =~ SKIPPED_STRING_DESCRIPTOR) }
    process_command(commands)
    puts "Response - #{@response}"
    @response
  end

  def process_command(commands)
    puts "Command - #{commands}"
    command_type = commands[0]
    puts "command type = #{command_type}"

    case command_type.upcase
    when 'PING'
      process_ping
    when 'ECHO'
      process_simple_string(commands[1])
    when 'SET'
      puts "when set commands: #{commands}"
      process_set({ key: commands[1], value: commands[2] })
    when 'GET'
      process_get(commands[1])
    end
  end

  def process_set(command)
    puts "process_set comman: #{command}"
    Storage.instance.set_value(command[:key], command[:value])
    process_simple_string('OK')
  end

  def process_get(key)
    value = Storage.instance.get_value(key)
    process_simple_string(value)
  end

  def process_ping
    process_simple_string('PONG')
  end

  def process_simple_string(display_string)
    @response += "+#{display_string}\r\n"
  end
end

class RedisServer
  MAX_REQUEST_LENGTH = 1024
  def initialize(port)
    @port = port
    @server = TCPServer.new(port)
    @clients = []
  end

  def listen
    loop do
      fds_to_watch = [@server, *@clients]
      ready_to_read, = IO.select(fds_to_watch)
      ready_to_read.each do |ready|
        if ready === @server
          @clients << @server.accept
        else
          handle_client(ready)
        end
      end
    end
  end

  def handle_client(client)
    request = client.readpartial(MAX_REQUEST_LENGTH)
    response = Parser.new(request).parse
    client.write(response)
  rescue EOFError
    client.close
    @clients.delete(client)
    puts 'Client disconnected.'
  end
end

RedisServer.new(6379).listen

# frozen_string_literal: true

require 'socket'
require 'date'

require_relative './storage.rb'
require_relative './parser.rb'

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
  
  private

  def handle_client(client)
    request = client.readpartial(MAX_REQUEST_LENGTH)
    command = Parser.new(request).parse
    response = process_command(command)
    client.write(response)
  rescue EOFError
    client.close
    @clients.delete(client)
    puts 'Client disconnected.'
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
      process_set({ key: commands[1], value: commands[2], exp: commands[4] })
    when 'GET'
      process_get(commands[1])
    end
  end
  
  def process_set(command)
    Storage.instance.set_value(command[:key], command[:value], command[:exp])
    process_simple_string('OK')
  end
  
  def process_get(key)
    value = Storage.instance.get_value(key)
  
    if value[:exp]
      millisecond_now = DateTime.now.strftime('%Q').to_i
      millisecond_now > value[:exp] ? process_null : process_simple_string(value[:value])
    else
      process_simple_string(value[:value])
    end
  end
  
  def process_ping
    process_simple_string('PONG') 
  end
  
  def process_simple_string(display_string)
    @response = "+#{display_string}\r\n"
  end
  
  def process_null
    @response = "$-1\r\n"
  end  
end

RedisServer.new(6379).listen
require "socket"

class Parser
  SKIPPED_STRING_DESCRIPTOR = ['$', '*']
  
  def initialize(message)
    @message = message
    @response = ''
    @last_processed_command = ''
  end

  def parse
    puts "Message to parse - #{@message}"
    @message.split("\r\n").each_with_index do |command|
      process_command(command)
    end
    puts "Response - #{@response}"
    @response
  end
  
  def process_command(command)
    puts "Command - #{command}"
    command_type = command[0]
    puts "command type = #{command_type}"
    return if SKIPPED_STRING_DESCRIPTOR.include?(command_type)

    case command.upcase
      when 'PING'
        process_ping(command.upcase)
    end

    case @last_processed_command
    when 'echo'
      process_simple_string(command)
    end
    
    @last_processed_command = command
  end
  
  def process_ping(_command)
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
      ready_to_read, _, _ = IO.select(fds_to_watch)
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
      puts "Client disconnected."
  end
end

RedisServer.new(6379).listen
require "socket"

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
    client.readpartial(MAX_REQUEST_LENGTH)
    client.write("+PONG\r\n")
    rescue EOFError
      client.close
      @clients.delete(client)
      puts "Client disconnected."
  end
end

RedisServer.new(6379).listen

require "socket"

class RedisServer
  MAX_REQUEST_LENGTH = 1024
  def initialize(port)
    @port = port
  end

  def start

    server = TCPServer.new(@port)
    s = server.accept

    loop do
      s.recv(MAX_REQUEST_LENGTH)
      s.puts "+PONG\r\n"
      rescue Errno::ECONNRESET
        puts "The connection is terminated by the client."
      break
    end
    s.close
  end
end

RedisServer.new(6379).start

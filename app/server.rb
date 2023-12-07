require "socket"

class YourRedisServer
  def initialize(port)
    @port = port
  end

  def start

    server = TCPServer.new(@port)
    s = server.accept
    s.puts "+PONG\r\n"
    s.close
  end
end

YourRedisServer.new(6379).start

require 'json'
require 'socket'

require './producer'
require './consumer'

class Server
  def initialize(host, port, request_config, response_config)
    @host = host
    @port = port
    @request_config = request_config.clone
    @response_config = response_config.clone

    @file_descriptors = {}
    @server = nil
    @producer = nil
    @consumer = nil
  end

  def start
    @producer = Producer.new(@request_config)

    @consumer = Consumer.new(@response_config)
    @consumer.start do |message|
      response_received(message)
    end

    @server = TCPServer.new(@host, @port)
    loop do
      Thread.new(@server.accept, @producer) do |client, producer|
        begin
          puts "connected: #{client.fileno}"
          add_file_descriptor(client.fileno)

          headers = []
          while (line = client.gets).chomp != ''
            headers << line
          end
          puts "header: #{headers.join()}"

          producer.send_message({fd: client.fileno, header: "#{headers.join}"})
        rescue Exception => exception
          puts "error: #{exception.message}"
        end
      end
    end
  end

  def end
    puts 'shutting down producer'
    @producer.shutdown
    puts 'shutting down consumer'
    @consumer.end

    puts 'closing all fd'
    close_file_descriptors
    puts 'shutting down server'
    @server.close
  end

  private

  def response_received(message)
    file_descriptor = message['fd']
    puts "fd: #{file_descriptor}"

    @file_descriptors.delete(file_descriptor)

    headers = [
      'HTTP/1.1 200 OK',
      'Server: unko',
      'Content-Type: text/html'
    ]
    client_socket = Socket.for_fd(file_descriptor)
    client_socket.print headers.join("\r\n")
    client_socket.print "\r\n\r\n"
    client_socket.print "#{message['body']}"
    client_socket.print "\r\n"
    client_socket.close
  end

  def add_file_descriptor(file_descriptor)
    puts "duplicated fd: #{file_descriptor}" if @file_descriptors.has_key?(file_descriptor)
    @file_descriptors[file_descriptor] = file_descriptor
  end

  def close_file_descriptors
    @file_descriptors.each_key do |file_descriptor|
      print "\tclosing[#{file_descriptor}]: "
      begin
        headers = [
          'HTTP/1.1 500 Internal Server Error',
          'Server: unko',
          'Content-Type: text/plain'
        ]
        client_socket = Socket.for_fd(file_descriptor)
        client_socket.print headers.join("\r\n")
        client_socket.print "\r\n\r\n"
        client_socket.close
        puts "ok"
      rescue Exception => exception
        puts "failed: #{exception.message}"
      end
    end
  end
end

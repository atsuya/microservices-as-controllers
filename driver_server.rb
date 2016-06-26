require './server'

Signal.trap('INT') do
  puts 'SIGINT detected: shutting down'
  @server.end
  exit
end

request_config = {
  broker: 'localhost:9092',
  topic: 'http-request',
  client_id: 'request-server'
}
response_config = {
  broker: 'localhost:9092',
  topic: 'http-response',
  client_id: 'response-server'
}
@server = Server.new('localhost', 3000, request_config, response_config)
@server.start

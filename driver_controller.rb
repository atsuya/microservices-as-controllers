require './items_controller'

Signal.trap('INT') do
  puts 'SIGINT detected: shutting down'
  @controllers.each do |controller|
    controller.end
  end

  exit
end

request_config = {
  broker: 'localhost:9092',
  topic: 'http-request',
  client_id: 'request-controller'
}
response_config = {
  broker: 'localhost:9092',
  topic: 'http-response',
  client_id: 'response-controller'
}

@controllers = []
[ItemsController].each_with_index do |controller_class, index|
  req_config = request_config.merge({ client_id: request_config[:client_id] + index.to_s })
  res_config = response_config.merge({ client_id: response_config[:client_id] + index.to_s })
  puts req_config
  puts res_config

  controller = controller_class.new(req_config, res_config)
  controller.start
  @controllers << controller
end

loop do
  sleep 1
end

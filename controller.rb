require 'json'
require 'stringio'
require 'webrick'

require './producer'
require './consumer'

class Controller
  def initialize(request_config, response_config)
    @request_config = request_config.clone
    @response_config = response_config.clone
  end

  def start
    @producer = Producer.new(@response_config)

    @consumer = Consumer.new(@request_config)
    @consumer.start do |message|
      request_received(message)
    end
  end

  def end
    @consumer.end
    @producer.shutdown
  end

  protected

  def want_to_process?(request)
    raise Exception.new('Not implemented')
  end

  def process_request(request)
    raise Exception.new('Not implemented')
  end

  def request_received(message)
    request = WEBrick::HTTPRequest.new(WEBrick::Config::HTTP)
    request.parse(StringIO.new(message['header']))

    if want_to_process?(request)
      body = process_request(request)
      @producer.send_message({fd: message['fd'], body: body})
    end
  end
end

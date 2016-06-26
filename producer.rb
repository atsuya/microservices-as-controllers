require 'json'

require './kafka_utility'

class Producer
  def initialize(config)
    @config = config.clone

    @kafka_utility = KafkaUtility.new(@config)
    @producer = @kafka_utility.instance.producer
  end

  def send_message(message)
    puts "sending message[#{@config[:topic]}]: #{message}"
    @producer.produce(JSON.generate(message), topic: @config[:topic])
    @producer.deliver_messages
  end

  def shutdown
    @producer.shutdown
    @kafka_utility.close
  end
end

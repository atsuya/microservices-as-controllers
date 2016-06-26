require 'json'

require './kafka_utility'

class Consumer
  def initialize(config)
    @config = config.clone

    @kafka_utility = KafkaUtility.new(@config)
    @thread = nil
    @shutdown_reqeusted = false
  end

  def start
    @thread = Thread.new do
      begin
        offset = :latest
        partition = 0

        while !@shutdown_requested do
          puts 'fetching messages'
          messages = @kafka_utility.instance.fetch_messages(
            topic: @config[:topic],
            partition: partition,
            offset: offset
          )

          messages.each do |message|
            puts "received: #{message.value}"
            offset = message.offset + 1
            yield(JSON.parse(message.value))
          end
        end
      rescue Exception => exception
        puts "consumer got exception: #{exception.message}"
      end
    end
  end

  def end
    @shutdown_requested = true
    @thread.join
    @kafka_utility.close
  end
end

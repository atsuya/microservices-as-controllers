require 'rubygems'
require 'bundler/setup'

require 'kafka'

class KafkaUtility
  attr_reader :instance

  def initialize(config)
    #logger = Logger.new($stderr)
    @instance = Kafka.new(
      seed_brokers: config[:broker],
      client_id: config[:client_id]
    )
  end

  def close
    @instance.close
  end
end

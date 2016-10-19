require 'bunny'

def logger
  @logger ||= Logger.new(STDOUT)
end

bunny = Bunny.new

logger.info('Opening TCP connection to RabbitMQ intance')
bunny.start

logger.info('Connection established, creating channel')
channel = bunny.create_channel

logger.info('Creating/Getting handle for exchange')
exchange = channel.topic('my.little.pony.topic')

logger.info('Creating/Getting handle for queue')
simple = channel.queue('my.consumer.simple')

simple.bind(exchange, routing_key: '*')

begin
  logger.info('Subscribing to messages')
  simple.subscribe(block: true) do |_delivery_info, _properties, payload|
    logger.info("The simple consumer got a message: #{payload}")
  end
rescue Interrupt
  channel.close
  bunny.close
  exit
end

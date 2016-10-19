require 'bunny'

def logger
  @logger ||= Logger.new(STDOUT)
end

bunny = Bunny.new

logger.info('Opening TCP connection to RabbitMQ intance')
bunny.start

logger.info('Connection established, creating channel')
channel = bunny.create_channel

logger.info('Creating/Getting RPC queue')
queue = channel.queue('my.consumer.converter')

begin
  logger.info('Subscribing to messages')
  queue.subscribe(block: true) do |_delivery_info, properties, payload|
    logger.info("The Converter got a message '#{payload}', starting the conversion...")

    ret = payload.upcase

    sleep(5)

    logger.info('Returning the converted value to the reply_to queue')

    channel.default_exchange.publish(ret,
                                     routing_key: properties.reply_to,
                                     correlation_id: properties.correlation_id)
  end
rescue Interrupt
  channel.close
  bunny.close
  exit
end

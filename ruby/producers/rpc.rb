require 'bunny'
require 'securerandom'

def logger
  @logger ||= Logger.new(STDOUT)
end

bunny = Bunny.new

logger.info('Opening TCP connection to RabbitMQ intance')
bunny.start

logger.info('Connection established, creating channel')
channel = bunny.create_channel

logger.info('Creating/Getting handle for a random queue name')
callback_queue = channel.queue('', exclusive: true)

correlation_id = SecureRandom.uuid

mutex = Mutex.new
condition = ConditionVariable.new

return_value = nil

logger.info("Listening to callback queue #{callback_queue.name}")
callback_queue.subscribe do |_delivery_info, properties, payload|
  if properties.correlation_id == correlation_id
    return_value = payload
    mutex.synchronize { condition.signal }
  end
end

channel.default_exchange.publish('I need to be converted', routing_key: 'my.consumer.converter', reply_to: callback_queue.name, correlation_id: correlation_id)

mutex.synchronize { condition.wait(mutex) }

logger.info("Conversion done: #{return_value}")

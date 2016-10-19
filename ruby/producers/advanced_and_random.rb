require 'bunny'
require 'parallel'

logger = Logger.new(STDOUT)

bunny = Bunny.new

logger.info('Opening TCP connection to RabbitMQ intance')
bunny.start

logger.info('Connection established, creating channel')
channel = bunny.create_channel

logger.info('Creating/Getting handle for exchange and queue')
exchange = channel.topic('my.little.pony.topic')

begin
  arr = [
    ['Publish to the RED', 'color.red'],
    ['Publish to the BLACK', 'color.black'],
    ['Publishing to all queues', 'all'],
    ['Publish to NACK', 'nack']
  ]
  count = (ARGV[0] || 1).to_i

  logger.info("Publishing #{count} random message(s)")

  Parallel.each(1..count, progress: 'Random publishing') do |_i|
    sample = arr.sample
    exchange.publish(sample.first, routing_key: sample.last)
  end

rescue Interrupt
  channel.close
  bunny.close
  exit
end

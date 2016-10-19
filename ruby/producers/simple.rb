require 'bunny'

logger = Logger.new(STDOUT)

bunny = Bunny.new

logger.info('Opening TCP connection to RabbitMQ intance')
bunny.start

logger.info('Connection established, creating channel')
channel = bunny.create_channel

logger.info('Creating/Getting handle for exchange')
exchange = channel.topic('my.little.pony.topic')

logger.info('Publishing message to exchange')
exchange.publish("This is a message with the timestamp #{Time.now}", routing_key: 'simple')

channel.close
bunny.close

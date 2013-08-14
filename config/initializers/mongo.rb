MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
#TODO Fix this in production
MongoMapper.database = "#flash_deal-production"

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    MongoMapper.connection.connect if forked
  end
end

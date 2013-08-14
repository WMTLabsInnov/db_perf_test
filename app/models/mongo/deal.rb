class Mongo::Deal
  include MongoMapper::Document

  key :name,        String
  key :wmt_id,      Integer
  key :available_quantity, Integer
  key :start_at, Time
  key :end_at, Time
  timestamps!
end

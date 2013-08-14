class Mysql::Pin < ActiveRecord::Base
  include Tire::Model::Search
  # include Tire::Model::Callbacks

  # belongs_to :wmt_product, foreign_key: :wm_id
  # belongs_to :pinner, foreign_key: :pinner_id

  establish_connection Rails.configuration.database_configuration["pindb"]

  class << self
    def import_to_es
      find_in_batches do |pin_group|
        index.import pin_group
      end
    end

    def import_to_mongo
      find_in_batches do |pin_group|
        pins = pin_group.inject([]) do |pins, mysql_pin|
          data = mysql_pin.attributes
          data['p_id'] = data.delete("id")
          mongo_pin = Mongo::Pin.build(data).attributes
          pins << mongo_pin
        end
        Mongo::Pin.collection.insert(pins)
      end
    end

    def fill_empty_records_to_es
      difference = Mysql::Pin.count - Pin.all.total
      difference.times do |i|
        empty_pin = Pin.new(source: "empty filled", updated_at: Time.now, created_at: Time.now)
        empty_pin.save
      end
    end
  end
end

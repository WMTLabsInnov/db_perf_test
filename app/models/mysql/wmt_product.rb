class Mysql::WmtProduct < ActiveRecord::Base
  has_many :pins, foreign_key: :wm_id

  include Tire::Model::Search
  # include Tire::Model::Callbacks

  establish_connection Rails.configuration.database_configuration["pindb"]

  class << self
    def import_to_es
      # find_in_batches do |pin_group|
        # index.import pin_group
      # end
    end
  end
end



class Mysql::Pinner < ActiveRecord::Base
  include Tire::Model::Search

  has_many :pins, foreign_key: :pinner_id
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


require 'elastic_search_model_extension'
class BrPin
  include Tire::Model::Persistence
  extend Tire::Model::Extension

  index_name('mysql_br_pins')
  document_type('mysql/br_pin')

  property :actions_count
  property :board_cat
  property :board_name
  property :board_url
  property :comments_count
  property :created_at
  property :description
  property :error_404
  property :img_src
  property :like_count
  property :pin_at
  property :pinned_count
  property :pinner
  property :pinner_id
  property :ran_resolver
  property :source
  property :title
  property :repins_count
  property :updated_at
  property :wm_id
  property :social_rank
  property :p_type
  property :price


  #Don't remove, this is needed to generate correct index mapping
  mapping {}

  class << self
    #use the Mysql::BrPin method to build the ES one
    def build_sample_pin
      br_pin = self.new(Mysql::BrPin.build_sample_pin.attributes)
    end

  end
end



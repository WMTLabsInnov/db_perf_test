require 'elastic_search_model_extension'


class Deal

  include Tire::Model::Persistence
  extend Tire::Model::Extension

  property :wmt_id, :type => 'integer', :index => 'not_analyzed'
  property :name, :type => 'string', :index => 'not_analyzed'
  property :available_quantity, :type => 'integer', :index => 'not_analyzed'
  property :start_at, :type => 'date', :index => 'not_analyzed'
  property :end_at, :type => 'date', :index => 'not_analyzed'

  #Don't remove, this is needed to generate correct index mapping
  mapping {}

end

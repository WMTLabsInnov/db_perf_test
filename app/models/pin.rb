require 'elastic_search_model_extension'


class Pin
  include Tire::Model::Persistence
  extend Tire::Model::Extension

  index_name('mysql_pins')
  document_type('mysql/pin')

=begin
  property :tire_size, :type => 'string', :index => 'not_analyzed'
  property :section_width, :type => 'float', :index => 'not_analyzed'
  property :aspect_ratio, :type => 'float', :index => 'not_analyzed'
  property :radial_construction, :type => 'string', :index => 'not_analyzed'
  property :rim_diameter, :type => 'float', :index => 'not_analyzed'

  property :load_rating, :type => 'integer', :index => 'not_analyzed'
  property :load_rating_translation, :type => 'string', :index => 'not_analyzed'
  property :load_rating_numeric, :type => 'integer', :index => 'not_analyzed'
  property :speed_rating, :type => 'string', :index => 'not_analyzed'
  property :speed_rating_translation, :type => 'string', :index => 'not_analyzed'
  property :speed_rating_numeric, :type => 'intege
=end

  property :actions_count, :type => 'integer',  :index => 'not_analyzed'
  property :board_cat, :type => 'string',  :index => 'not_analyzed'
  property :board_name, :type => 'string',  :index => 'not_analyzed'
  property :board_url, :type => 'string',  :index => 'not_analyzed'
  property :comments_count, :type => 'integer',  :index => 'not_analyzed'
  property :created_at, :type => 'date',  :index => 'not_analyzed'
  property :description,  :type => 'string'
  property :error_404, :type => 'integer',  :index => 'not_analyzed'
  property :img_src,  :type => 'string',  :index => 'not_analyzed'
  property :like_count,  :type => 'integer',  :index => 'not_analyzed'
  property :pin_at, :type => 'date',  :index => 'not_analyzed'
  property :pinned_count,  :type => 'integer',  :index => 'not_analyzed'
  property :pinner,  :type => 'string',  :index => 'not_analyzed'
  property :pinner_id,  :type => 'string',  :index => 'not_analyzed'
  property :ran_resolver, :type => 'boolean',  :index => 'not_analyzed'
  property :source,  :type => 'string',  :index => 'not_analyzed'
  property :repins_count,  :type => 'integer',  :index => 'not_analyzed'
  property :title,  :type => 'string',  :index => 'not_analyzed'
  property :source,  :type => 'string',  :index => 'not_analyzed'
  property :updated_at, :type => 'date',  :index => 'not_analyzed'
  property :wm_id,  :type => 'string',  :index => 'not_analyzed'
  property :social_rank, :type => 'integer',  :index => 'not_analyzed'
  property :p_type,  :type => 'string',  :index => 'not_analyzed'
  property :price,  :type => 'string',  :index => 'not_analyzed'


  #Don't remove, this is needed to generate correct index mapping
  mapping {}


  class << self

    def import_to_mongo
      loop_all(batch_mode: true) do |pin_group|
        pins = pin_group.inject([]) do |pins, mysql_pin|
          pins << Mongo::Pin.build(mysql_pin.attributes).attributes
        end
        Mongo::Pin.collection.insert(pins)
      end
    end

    def social_rank

=begin
      #only enable when there is a primary size tire
      # primary_tire_factor = primary_sizes_str_list.blank? ? '1' :
        # "([#{primary_sizes_str_list}].contains(doc['tire_size'].stringValue) ? 10 : 1)"
      primary_tire_factor = primary_sizes_str_list.blank? ? '1' :
        "(primary_sizes.containsKey(doc['tire_size'].stringValue) ? 10 : 1)"

      availability_factor = "(doc['availability'].stringValue == 'Y' ? 1 : 1 / #{max_score})"

      #forumar to finding the lowest price tire and rank it on top
      # lowest_price_factor = lowest_price_tire ? "(doc['price'].value == #{lowest_price_tire.price} " +
        # "and doc['availability'].stringValue == 'Y' ? 1000 : 1)" : '1'

      #for boolean value, use 'T' or 'F' as literal in script expression
      rebate_available_factor = "(doc['has_rebate'].value == 'T' ? 1 : 1 / #{max_score})"
      #for boolean value, use 'T' or 'F' as literal in script expression
      rollback_available_factor = "(doc['is_rollback'].value == 'T' ? 1 : 1 / #{max_score})"

      scoring_formulars = {
        'recommended' => "_score * #{primary_tire_factor} * #{availability_factor} " +
        " * #{rating_score_factor} * #{logistics_distribution_over_price} ",
        'price_low_to_high' => "_score * (1 - doc['price'].value / 1000) * #{availability_factor}",
        'price_high_to_low' => "_score * (1 + doc['price'].value / 1000) * #{availability_factor}",
        'rebate_available' => "_score * #{rebate_available_factor} * #{availability_factor}",
        'rollback_available' => "_score * #{rollback_available_factor} * #{availability_factor}",
      }
=end

      per_page = 1
      result = ""
      (1..(all.total / per_page).floor + 1).each do |page|
        offset = page * per_page
        social_rank_formula = "doc['comments_count'].value * 10 + doc['repins_count'].value * 5 " +
          " + doc['comments_count'].value * 10 + doc['repins_count'].value * 5 " +
          " + doc['comments_count'].value * 10 + doc['repins_count'].value * 5 " +
          " + doc['comments_count'].value * 10 + doc['repins_count'].value * 5 " +
          " + doc['comments_count'].value * 10 + doc['repins_count'].value * 5 "

        result = filter_by_fields_with_custom_score(social_rank_formula, {},
          {offset: offset, limit: per_page} )
        # pp result.map { |i| "<#{i.id}>: #{i._score}" }
        break if page == 1
      end

      puts "sadf"
      result
    end

  end

end


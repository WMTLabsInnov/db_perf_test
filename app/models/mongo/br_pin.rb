class Mongo::BrPin
  include MongoMapper::Document


  key :actions_count, Integer
  key :p_id, String
  key :board_cat, String
  key :board_name, String
  key :board_url, String
  key :comments_count, Integer
  key :created_at, Time
  key :description, String
  key :error_404, Integer
  key :img_src, String
  key :like_count, Integer
  key :pin_at, Time
  key :pinned_count, Integer
  key :pinner, String
  key :pinner_id, String
  key :ran_resolver, Boolean
  key :source, String
  key :repins_count, Integer
  key :title, String
  key :source, String
  key :updated_at, Time
  key :wm_id, String
  key :social_rank, Integer
  key :p_type, String
  key :price, Float

  timestamps!

  class << self

    def build(attributes)
      pin = self.new
      attributes.each do |k, v|
        begin
          pin.send("#{k}=", v)
        rescue NoMethodError => e
          puts e.inspect
        end
      end
      pin
    end
  end

end



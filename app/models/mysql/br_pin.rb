class Mysql::BrPin < ActiveRecord::Base
  include Tire::Model::Search
  # include Tire::Model::Callbacks

  establish_connection Rails.configuration.database_configuration["pindb"]

  class << self
    def import_to_es
      find_in_batches do |pin_group|
        index.import pin_group
      end
    end

    def build_sample_pin
      br_pin = self.new(
        actions_count: 1,
        board_cat: 'test cat',
        board_name: 'test board',
        board_url: 'http://test.test/borda_url',
        comments_count: 1,
        created_at: Time.now,
        description: 'test test desc',
        error_404: 0,
        img_src: 'http://test.test/test.jpg',
        like_count: 1,
        pin_at: Time.now,
        pinned_count: 1,
        pinner: 'tester',
        pinner_id: 'tester_id',
        ran_resolver: 0,
        source: 'walmart.com',
        title: 'test br pin',
        updated_at: Time.now,
        wm_id: rand(1000000),
        social_rank: 1,
        p_type: nil,
        price: 1,
        repins_count: 1
      )
    end
  end
end


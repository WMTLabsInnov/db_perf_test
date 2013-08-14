class Mongo::Pin
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

    def random_100_ids
      per_page = 300
      random_ids = []
      (1..(self.count / per_page).ceil).each do |page|
        offset = (page - 1)* per_page
        query = self.sort(:created_at).skip(offset).limit(per_page)
        pins = query.all
        (0..(50 + rand(10))).each do |i|
          random_ids << pins[rand(per_page)].id.to_s
        end
        break if random_ids.size >= 100
      end
      random_ids[0..99]
    end

    def id_list
        ["52053408d3bb212a54000005",
   "52053408d3bb212a4f00000d",
   "52053409d3bb212a4e00000c",
   "52053407d3bb212a53000005",
   "52053408d3bb212a53000019",
   "52053409d3bb212a50000028",
   "52053408d3bb212a4d000005",
   "52053409d3bb212a54000016",
   "52053409d3bb212a5400001c",
   "52053409d3bb212a5300001f",
   "52053409d3bb212a4f00001a",
   "52053408d3bb212a4d00000b",
   "52053408d3bb212a4e000008",
   "52053409d3bb212a4f000023",
   "52053408d3bb212a54000009",
   "52053409d3bb212a54000027",
   "52053409d3bb212a4e000012",
   "52053407d3bb212a54000001",
   "52053408d3bb212a54000012",
   "52053408d3bb212a51000004",
   "52053409d3bb212a53000029",
   "52053408d3bb212a5100000f",
   "52053408d3bb212a51000004",
   "52053409d3bb212a4f000020",
   "52053409d3bb212a51000023",
   "52053408d3bb212a4e000003",
   "52053409d3bb212a5400001f",
   "52053409d3bb212a4f000018",
   "52053408d3bb212a4d000007",
   "52053408d3bb212a4d00000f",
   "52053408d3bb212a4f00000a",
   "52053409d3bb212a4d000016",
   "52053408d3bb212a5400000b",
   "52053408d3bb212a4f000008",
   "52053409d3bb212a52000019",
   "52053409d3bb212a5300001e",
   "52053409d3bb212a4e000019",
   "52053409d3bb212a4f000014",
   "52053409d3bb212a53000022",
   "52053409d3bb212a5300002a",
   "52053409d3bb212a52000020",
   "52053409d3bb212a51000023",
   "52053409d3bb212a53000023",
   "52053407d3bb212a50000006",
   "52053408d3bb212a52000007",
   "52053407d3bb212a4d000004",
   "52053409d3bb212a50000017",
   "52053408d3bb212a5400000d",
   "52053408d3bb212a5000000f",
   "52053408d3bb212a5300000e",
   "52053408d3bb212a4f00000c",
   "52053409d3bb212a5000001b",
   "52053409d3bb212a51000020",
   "52053408d3bb212a4f000006",
   "52053408d3bb212a51000012",
   "5205340ad3bb212a54000031",
   "5205340bd3bb212a51000042",
   "5205340bd3bb212a5100003b",
   "5205340ad3bb212a51000033",
   "5205340ad3bb212a50000033",
   "5205340ad3bb212a5100002f",
   "5205340ad3bb212a52000024",
   "5205340cd3bb212a50000052",
   "52053409d3bb212a5000002b",
   "5205340cd3bb212a4f000041",
   "5205340ad3bb212a52000029",
   "5205340ad3bb212a52000031",
   "5205340bd3bb212a50000044",
   "5205340ad3bb212a4e000022",
   "5205340bd3bb212a5000003e",
   "5205340bd3bb212a5100003b",
   "5205340ad3bb212a4e000020",
   "5205340bd3bb212a53000046",
   "5205340ad3bb212a50000031",
   "5205340bd3bb212a51000042",
   "5205340cd3bb212a50000053",
   "5205340cd3bb212a51000044",
   "5205340bd3bb212a4d000030",
   "5205340bd3bb212a50000046",
   "5205340ad3bb212a54000032",
   "5205340bd3bb212a4f000038",
   "5205340ad3bb212a50000030",
   "5205340bd3bb212a51000040",
   "5205340bd3bb212a4e000031",
   "5205340bd3bb212a50000044",
   "5205340ad3bb212a51000030",
   "5205340cd3bb212a4e000038",
   "5205340bd3bb212a5000003c",
   "5205340cd3bb212a54000048",
   "5205340cd3bb212a4d00003d",
   "5205340cd3bb212a5000004b",
   "5205340bd3bb212a4e000035",
   "5205340ad3bb212a5000003b",
   "5205340ad3bb212a4d00002f",
   "5205340ad3bb212a53000036",
   "5205340cd3bb212a51000044",
   "5205340ad3bb212a50000037",
   "5205340bd3bb212a5100003d",
   "5205340ad3bb212a52000033",
   "5205340cd3bb212a5300004f"]
    end
  end

end


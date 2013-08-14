class PinsController < ApplicationController
 respond_to :json

  ID_LIST = ["2462974768135499",
 "914862396406263",
 "1125968629154821",
 "3025924720585666",
 "3166662209754029",
 "4503668349727883",
 "7881368070628051",
 "7459155604872495",
 "10555380349286045",
 "10766486580926434",
 "10766486580926460",
 "10766486580926542",
 "5981411978264282",
 "6051780721272199",
 "6192518208063877",
 "6333255697128638",
 "8796161744284501",
 "8796161744665566",
 "8796161744799896",
 "9007267974912568",
 "8444318022189187",
 "13018286394571404",
 "13018286394571430",
 "13018286394571435",
 "13018286394571447",
 "13299761371924081",
 "11822017742113049",
 "11822017742676528",
 "14566398766086352",
 "14566398766101427",
 "14144186301450132",
 "15973773648810053",
 "19914423324445708",
 "19914423324445722",
 "20055160813514106",
 "20266267044646598",
 "18155204718969098",
 "26106872810882422",
 "26106872810882427",
 "26106872810882441",
 "26106872810882458",
 "26106872810882465",
 "26106872810882516",
 "26458716533022385",
 "22166223137994206",
 "24980972903202239",
 "23292123044075405",
 "27162403973231948",
 "27162403973393882",
 "26458716533793582",
 "26458716533793816",
 "26669822766124091",
 "29554941274997941",
 "30680841182915519",
 "30821578672386428",
 "30891947415850596",
 "31384528625130877",
 "33988172160229743",
 "34340015880870611",
 "34551122113145970",
 "34902965833602953",
 "36451078205971785",
 "36873290669728909",
 "36873290669728947",
 "36873290669728959",
 "36873290669728997",
 "43699058855501163",
 "43839796344186689",
 "41728734018364229",
 "40532465368032136",
 "40743571601641870",
 "40813940344068301",
 "40813940344068313",
 "40813940344248118",
 "38843615507963331",
 "41165784066676813",
 "41376890297610228",
 "49258189647335970",
 "49680402110241758",
 "49961877088674660",
 "47780446018216266",
 "46161964902234112",
 "53409945551950146",
 "53480314296479142",
 "51861833179951317",
 "52635889367773529",
 "52917364342800268",
 "52565520623803313",
 "52565520623803325",
 "55661745365408874",
 "55872851598535943",
 "55872851599384532",
 "56083957832508344",
 "50876670761934398",
 "56365432809060746",
 "56928382760552563",
 "59039445086539591",
 "60446819970671017",
 "60728294947309390",
 "60869032436031046"]

  def index
    @pins = filter_resource(Pin, params)
    respond_with(collection_attributes(@pins))
  end

  def show
    res = Pin.find(params[:id])
    respond_with(res.attributes)
  end

  def show_random
    # res = Pin.find(ID_LIST[rand(100)])
    res = Pin.search do
      query {all}
      sort { by :updated_at, 'desc' }
      size 50
    end
    respond_with(collection_attributes(res))
  end

  def es_random_lookup
    look_up_results = []
    100.times do |i|
      look_up_results <<  Pin.find(ID_LIST[rand(100)])
    end
    respond_with(collection_attributes(look_up_results))
  end

  def mysql_random_lookup
    look_up_results = []
    100.times do |i|
      look_up_results <<  Mysql::Pin.find(ID_LIST[rand(100)])
    end
    respond_with(collection_attributes(look_up_results))
  end

  def mongo_random_lookup
    look_up_results = []
    100.times do |i|
      look_up_results <<  Mongo::Pin.find_by_p_id(ID_LIST[rand(100)])
    end
    respond_with(look_up_results)
  end

  def es_find_the_latest_pins
    # res = Pin.find(ID_LIST[rand(100)])
    res = Pin.search do
      query {all}
      sort { by :updated_at, 'desc' }
      size 50
    end
    respond_with(collection_attributes(res))
  end

  def mysql_find_the_latest_pins
    res = Mysql::Pin.order('updated_at desc').limit(50)
    respond_with(collection_attributes(res))
  end

  def mongo_find_the_latest_pins
    query = Mongo::Pin.sort(:updated_at.desc).limit(50)
    res = query.all
    respond_with(collection_attributes(res))
  end

  def mysql_get_distinct_values
    field_name = params[:field]
    res = Mysql::Pin.select(field_name.to_sym).distinct.limit(100)
    respond_with(res.map(&field_name.to_sym))
  end

  def es_get_distinct_values
    field_name = params[:field]
    res = Pin.all_selections(field_name.to_sym, {}, 100)
    respond_with(res)
  end

  def mongo_get_distinct_values
    field_name = params[:field]
    res = Mongo::Pin.collection.distinct(field_name, {})[0..100]
    respond_with(res)
  end


  def mysql_update_a_pin
    pin_id = params[:id]
    pin = Mysql::Pin.find(pin_id)
    pin.like_count += 1
    pin.save
    respond_with(pin)
  end

  def es_update_a_pin
    pin_id = params[:id]
    pin = Pin.find(pin_id)
    pin.like_count += 1
    pin.save
    respond_with(pin)
  end

  def mongo_update_a_pin
    pin_id = params[:p_id]
    pin = Mongo::Pin.find_by_p_id(pin_id)
    pin.like_count += 1
    pin.save
    respond_with(pin)
  end


  def mysql_create_a_br_pin
    pin = Mysql::BrPin.build_sample_pin
    pin.save
    respond_with(pin)
  end

  def es_create_a_br_pin
    pin = BrPin.build_sample_pin
    es_pin = Pin.new(pin.attributes)
    es_pin.save
    respond_with(es_pin)
  end

  def mongo_create_a_br_pin
    pin = BrPin.build_sample_pin
    mongo_pin = Mongo::Pin.build(pin.attributes)
    mongo_pin.save
    respond_with(mongo_pin)
  end

  def mysql_factes_on_fields
    fields = params[:fields].map do |field|
      field.to_sym
    end

    fields_facet = {}

    fields.each do |field|
      res = Mysql::Pin.select(field).distinct
      fields_facet[field] = res.map(&field)
    end
    respond_with(fields_facet)
  end

  def es_factes_on_fields
    fields = params[:fields].map do |field|
      field.to_sym
    end

    res = Pin.filterd_facets(fields, {})
    fields_facet = {}

    fields.each do |field|
      fields_facet[field] = res[field.to_s]["terms"].map { |t| t['term']}
    end

    respond_with(fields_facet)
  end

  def mysql_look_up_with_attributes_in_other_tables
   #joins
   pinner_id = params[:pinner_id] || "pinkpeach1986"
   pinner_id = "pinkpeach1986"
   result =  Mysql::Pinner.includes(:pin).where(id: pinner_id).limit(10)
   #something wrong with the json rendering
   respond_with(result.to_json(:include => [:pinner, :wmt_product]))
  end

end

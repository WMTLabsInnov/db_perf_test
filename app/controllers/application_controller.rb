class ApplicationController < ActionController::Base
  CONTROLLER_PARAMS = [:controller, :action, :format]

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def filter_resource(res_klass, filter_params)
    limit = filter_params.delete(:limit) || 100
    offset = filter_params.delete(:offset) || 0

    filter_fields = filter_params.inject({}) do |filter_fields, (field, value)|
      if !value.blank? and !CONTROLLER_PARAMS.include?(field.to_sym)
        filter_fields[field] = value
      end
      filter_fields
    end

    records = res_klass.filter_by_fields(filter_fields,
      offset: offset, limit: limit)
  end

  #this is for rendering json tha way ActiveRecord resource do
  #params:
  #  collection <array>: the array of the model objects
  #  dynamic_attributes <array>: attribute that's not persisted in data store, but needed to
  #    be serialized for front-end used
  #return:
  #  array of model attributes in hash form
  def collection_attributes(collection, dynamic_attributes = [])
    collection.map do |r|
      r.attributes.merge!(
        dynamic_attributes.each_with_object({}) do |attr, dynamic_attrs|
          dynamic_attrs[attr] = r.send(attr.to_sym)
        end
      )
    end
  end


end

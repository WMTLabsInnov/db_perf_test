class DealsController < ApplicationController
  respond_to :json, :html

  def index
    @deals = filter_resource(Deal, params)

    respond_with(collection_attributes(@deals))
  end

  def show
    res = Deal.find(params[:id])
    respond_with(res.attributes)
  end

end

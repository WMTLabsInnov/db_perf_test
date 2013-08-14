class HomeController < ApplicationController
  def index
    render text: 'h' * 5000
  end
end

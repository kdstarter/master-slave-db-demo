class Api::DashboardController < ApplicationController
  include Api::DashboardHelper

  def index
    data = { primary: {}, primary_replica: {} }
    data.keys.each do |which_db|
      data[which_db] = fetch_all_count_cache(which_db)
    end
    render json: data
  end
end

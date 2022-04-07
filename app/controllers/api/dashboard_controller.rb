class Api::DashboardController < Api::BaseController
  include Api::DashboardHelper
  skip_before_action :authenticate_user!, only: [:index]

  def index
    data = { primary: {}, replica: {} }
    data.keys.each do |which_db|
      db_data = fetch_all_count_cache(which_db)
      data[which_db] = db_data
    end
    render json: data
  end

  def mock_mix_action
    mock_random_action
  end
end

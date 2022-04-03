class Api::BaseController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :authenticate_user!

  def authenticate_user!
    user_auth = request.headers['Authorization'].to_s
    current_user(user_auth)
    head :unauthorized unless @current_user
  end

  def current_user(user_auth = '')
    return @current_user if @current_user

    if user_auth.to_i > 0
      @current_user = User.find_by(id: user_auth.to_i)
    elsif user_auth.include?('-')
      # using randon user
      user_id1, user_id2 = user_auth.split('-').map(&:to_i)
      if user_id2 > user_id1
        @current_user = User.where(id: (user_id1..user_id2)).sample
      end
    end
    @current_user
  end

  def pager_params(params)
    {
      current_page: params[:page] || 1,
      per_page: params[:per_page] || 20
    }
  end

  def render_json_pages(data)
    pager = pager_params(params)
    data = data.page(pager[:page]).per(pager[:per_page])

    pager[:total_pages] = data.total_pages
    render json: { current_user: current_user, pager: pager, data: data }
  end
end

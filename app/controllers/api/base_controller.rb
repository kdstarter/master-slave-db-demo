class Api::BaseController < ActionController::Base
  include FakeDataHelper
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!

  def authenticate_user!
    user_auth = request.headers['Authorization'].to_s
    current_user(user_auth)
    head :unauthorized unless @current_user
  end

  def current_user(user_auth = '')
    return @current_user if @current_user
    if user_auth.include?('-')
      # using randon fake user
      @current_user = fake_range_user(user_auth)
    elsif user_auth.to_i > 0
      @current_user = User.find_by(id: user_auth.to_i)
    end
    @current_user
  end

  def pager_params(params)
    {
      current_page: params[:page] || 1,
      per_page: params[:per_page] || 20
    }
  end

  def render_json_one(data = {})
    hash = { current_user: current_user }
    if data.is_a? Hash
      hash.merge!(data)
    else
      hash[:data] = data
    end
    render json: hash
  end

  def render_json_pages(data)
    pager = pager_params(params)
    if data.blank?
      data = []
      pager[:total_pages] = 1
    else
      data = data.page(pager[:page]).per(pager[:per_page])
      pager[:total_pages] = data.total_pages
    end

    if data.first.is_a? Product
      data = data.as_json(with_owner: true)
    end
    render json: { current_user: current_user, pager: pager, data: data }
  end
end

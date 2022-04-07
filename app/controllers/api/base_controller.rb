class Api::BaseController < ActionController::Base
  include FakeDataHelper
  include Api::ProductsHelper
  include Api::OrdersHelper

  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token
  before_action :log_action_start, :authenticate_user!
  after_action :log_action_end

  WARN_API_SEPENT = 0.5 # Seconds
  ALL_API_REQ_COUNTER = 'all_api_req_counter'
  WARN_API_REQ_COUNTER = 'warn_api_req_counter'

  MOCK_ACTIONS = [
    'GET@/api/products', 'POST@/api/products',
    'GET@/api/orders', 'POST@/api/orders', 'PUT@/api/orders/random_id'
  ]

  def mock_random_action
    @mock_action = MOCK_ACTIONS[Random.rand(MOCK_ACTIONS.length-1)].split('@')
    proxy_req_action(@mock_action[0], @mock_action[1])
  end

  def proxy_req_action(req_method = nil, req_path = nil)
    req_method, req_path = _auto_path_counter.split('@') if req_path.blank?

    if req_method == 'GET' && req_path == '/api/products'
      product_index_action
    elsif req_method == 'POST' && req_path == '/api/products'
      product_create_action
    elsif req_method == 'GET' && req_path == '/api/orders'
      order_index_action
    elsif req_method == 'POST' && req_path == '/api/orders'
      order_create_action
    elsif req_method == 'PUT' && req_path == '/api/orders/random_id'
      order_update_action
    else
      raise "Unknown proxy #{_auto_path_counter}"
    end
  end

  def debug_logger
    @debug_logger ||= Logger.new('log/debug.log')
  end

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

  protected
  # for all request path
  def api_request_count
     RedisClient.current.get(ALL_API_REQ_COUNTER).to_i
  end

  def warn_api_req_count
     RedisClient.current.get(WARN_API_REQ_COUNTER).to_i
  end

  # for specific request path
  def _auto_path_counter
    if @mock_action.present?
      "#{@mock_action[0]}@#{@mock_action[1]}"
    else
      "#{request.method}@#{request.path}"
    end
  end

  def _warn_auto_req_counter
    "warn#{_auto_path_counter}"
  end

  def auto_path_count
    RedisClient.current.get(_auto_path_counter).to_i
  end

  def warn_auto_req_count
    RedisClient.current.get(_warn_auto_req_counter).to_i
  end

  def log_action_start
    RedisClient.current.incr(_auto_path_counter)
    RedisClient.current.incr(ALL_API_REQ_COUNTER)
    @action_start_at = Time.now.to_f
  end

  def log_action_end
    @action_end_at = Time.now.to_f
    @action_spent_s = (@action_end_at - @action_start_at).round(2)
    if @action_spent_s > WARN_API_SEPENT
      RedisClient.current.incr(_warn_auto_req_counter)
      RedisClient.current.incr(WARN_API_REQ_COUNTER)

      counter_msg = "#{'Mock' if @mock_action.present?} #{_auto_path_counter} #{warn_auto_req_count}th/#{auto_path_count} delay"
      debug_msg = "#{counter_msg}, #{warn_api_req_count}th/#{api_request_count} user #{current_user&.id} resp in #{@action_spent_s}S"
      puts debug_msg
      # debug_logger.warn(debug_msg)
    end
  end

  def render_json_one(data = {})
    hash = { mock_action: @mock_action, current_user: current_user }
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

    render json: { mock_action: @mock_action,
      current_user: current_user, pager: pager, data: data }
  end

end

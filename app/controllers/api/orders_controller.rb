class Api::OrdersController < Api::BaseController
  skip_before_action :authenticate_user!, only: [:update]

  def index
    proxy_req_action
  end

  def create
    proxy_req_action
  end

  def update
    proxy_req_action
  end
end

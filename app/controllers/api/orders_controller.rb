class Api::OrdersController < Api::BaseController
  skip_before_action :authenticate_user!, only: [:update]

  def index
    if params[:scope] = 'my'
      @orders = current_user.orders
    else
      @orders = Order.all
    end

    render_json_pages @orders
  end

  def create
    @order = fake_user_create_order(current_user)
    render_json_one(order: @order)
  end

  def update
    random_order = Order.unpaid.sample
    @current_user = random_order.user
    @order = fake_update_order_status(random_order)
    render_json_one(order: @order)
  end
end

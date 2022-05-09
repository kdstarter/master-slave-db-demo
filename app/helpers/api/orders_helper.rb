module Api::OrdersHelper
  # for proxy order actions
  def order_index_action
    if params[:scope] = 'my'
      @orders = current_user.orders
    else
      @orders = Order.all
    end
    render_json_pages @orders
  end

  def order_create_action
    @order = fake_user_create_order(current_user)
    render_json_one(order: @order)
  end

  def order_update_action
    random_order = Order.unpaid.sample
    if random_order.blank?
      render_json_one(order: {})
    else
      @current_user = random_order.user
      @order = fake_update_order_status(random_order)
      render_json_one(order: @order)
    end
  end

end

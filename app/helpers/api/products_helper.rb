module Api::ProductsHelper
  # for proxy product actions
  def product_index_action
    if params[:scope] = 'my'
      @products = current_user.products
    else
      @products = Product.all
    end
    render_json_pages @products
  end

  def product_create_action
    @product = fake_user_product(current_user)
    render_json_one(product: @product)
  end

end

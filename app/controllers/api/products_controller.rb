class Api::ProductsController < Api::BaseController
  def index
    @products = Product.all
    render_json_pages @products
  end

  def create
    @product = fake_user_product(current_user)
    render_json_one(product: @product)
  end
end

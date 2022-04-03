class Api::ProductsController < Api::BaseController
  def index
    @products = Product.all
    render_json_pages @products
  end

  def create

  end
end

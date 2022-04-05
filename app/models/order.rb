class Order < ApplicationRecord
  belongs_to :user
  belongs_to :product

  enum status: { unpaid: 0, closed: 1, success: 2 }

  default_scope -> { order(id: :desc) }

  before_create :calc_price

  def as_json(options = {})
    hash = super.as_json
    hash[:user_name] = user.name
    hash[:product] = product
    hash
  end

  protected
  def calc_price
    self.total_price = pd_amount * product.pd_price
  end

  def make_pay_closed
    update_attributes(status: :closed)
  end

  def make_pay_success
    update_attributes(status: :success)
  end
end

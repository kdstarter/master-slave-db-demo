class Order < ApplicationRecord
  belongs_to :user
  belongs_to :product

  enum status: { unpaid: 0, closed: 1, success: 2 }
  before_create :calc_price

  protected
  def calc_price
    self.total_price = pd_amount * product.pd_price
  end
end

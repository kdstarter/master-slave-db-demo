class Order < ApplicationRecord
  belongs_to :user
  belongs_to :product

  enum status: { unpaid: 0, closed: 1, successful: 2 }

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

  def update_pay_status(status)
    unless status.to_s == 'successful'
      update!(status: status)
    else
      Order.transaction do
        user.send(:update_credit, -total_price)
        product.owner.send(:update_credit, total_price)
        update!(status: status)
      end
    end
  end
end

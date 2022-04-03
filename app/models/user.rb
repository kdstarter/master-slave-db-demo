class User < ApplicationRecord
  has_many :products, foreign_key: :owner_id
  has_many :orders, dependent: :destroy

  def as_json(options = {})
    {
      id: id,
      name: name
    }
  end
end

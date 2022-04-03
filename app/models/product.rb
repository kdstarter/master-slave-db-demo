class Product < ApplicationRecord
  belongs_to :user, foreign_key: :owner_id
  has_many :orders, dependent: :destroy

  def as_json(options = {})
    hash = super.as_json
    hash[:owner_name] = user.name
    hash
  end
end

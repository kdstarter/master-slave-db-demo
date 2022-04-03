class Product < ApplicationRecord
  belongs_to :user, foreign_key: :owner_id
  has_many :orders, dependent: :destroy

end

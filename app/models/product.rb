class Product < ApplicationRecord
  belongs_to :owner, class_name: :User, foreign_key: :owner_id
  has_many :orders, dependent: :destroy

  def as_json(options = {})
    hash = super.as_json
    hash[:owner_name] = owner.name if options[:with_owner]
    hash
  end
end

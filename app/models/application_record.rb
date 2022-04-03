class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  connects_to database: { primary: :primary }

  def as_json(options = {})
    hash = super.as_json
    hash.reject { |field| field.in?(%w(created_at updated_at)) }
  end
end

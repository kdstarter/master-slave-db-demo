class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  connects_to database: { writing: :primary, reading: :primary_replica }

  def as_json(options = {})
    hash = super.as_json
    hash.reject { |field| field.in?(%w(created_at updated_at)) }
  end
end

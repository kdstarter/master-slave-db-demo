class User < ApplicationRecord
  has_many :products, foreign_key: :owner_id
  has_many :orders, dependent: :destroy

  # validates_numericality_of :credit, greater_than_or_equal_to: 0

  def as_json(options = {})
    {
      id: id,
      name: name
    }
  end

  protected
  # Todo: ensure credit >= 0
  def update_credit(amount)
    retry_times = 0
    begin
      self.with_lock do
        update!(credit: credit + amount)
      end
    rescue ActiveRecord::StaleObjectError => e
      err_msg = "Failed update_credit user#{id} from #{credit} to #{credit + amount}, #{e.inspect}"
      DbClient.log_by(:error, err_msg)
      self.reload
      retry_times += 1
      retry_times <= 1 ? retry : raise(e.inspect)
    end
  end
end

module FakeDataHelper
  def fake_user_create_order(user)
    random_product = Product.all.sample
    order = user.orders.create!(status: :unpaid, 
      product_id: random_product.id, 
      pd_amount: Random.rand(1..10)
    )
  end

  def fake_update_order_status(order)
    random_status = %w(closed successful)[Random.rand(0..1)]
    order.send(:update_pay_status, random_status)
    order
  end

  def fake_range_user(user_auth)
    user_id1, user_id2 = user_auth.split('-').map(&:to_i)
    if user_id2 >= user_id1
      user_id = (user_id1..user_id2).to_a.sample
    else
      user_id = (user_id2..user_id1).to_a.sample
    end
    fake_name = "No.#{user_id} #{Faker::Name.name.split(' ').first}"

    # User.find_or_create_by!(id: user_id) { |user| user.name = fake_name }
    exist_data = nil
    DbClient.primary_replica_exec do
      exist_data = User.find_by(id: user_id)
    end
    return exist_data if exist_data.present?

    user_params = { id: user_id, name: fake_name }
    begin
      DbClient.primary_exec do
        exist_data = User.create!(user_params)
      end
    rescue ActiveRecord::ReadOnlyError => e
      err_msg = "Failed create user#{user_id}, #{e.inspect}"
      DbClient.log_by(:error, err_msg)
    end
    exist_data
  end

  def fake_user_product(user, limit_product = 1000)
    product_count = user.products.count(:id)
    if product_count >= limit_product
      user_product = user.products.sample
    else
      product_name = "No.#{product_count+1} #{Faker::Food.fruits}"
      exist_data = nil
      DbClient.primary_replica_exec do
        exist_data = user.products.find_by(name: product_name)
      end
      user_product = exist_data || user.products.create!(name: product_name,
        stock_amount: Random.rand(5400..5600),
        pd_price: Random.rand(0..9.99).round(2)
      )
    end
    user_product
  end
end

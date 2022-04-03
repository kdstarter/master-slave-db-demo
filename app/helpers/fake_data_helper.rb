module FakeDataHelper
  def fake_range_user(user_auth)
    user_id1, user_id2 = user_auth.split('-').map(&:to_i)
    if user_id2 >= user_id1
      user_id = (user_id1..user_id2).to_a.sample
    else
      user_id = (user_id2..user_id1).to_a.sample
    end
    fake_name = "No.#{user_id} #{Faker::Name.name.split(' ').first}"
    User.find_or_create_by!(id: user_id) { |user| user.name = fake_name }
  end

  def fake_user_product(user, limit_product = 25)
    product_count = user.products.count
    if product_count >= limit_product
      user_product = user.products.sample
    else
      product_name = "No.#{product_count+1} #{Faker::Food.fruits}"
      user_product = user.products.find_or_create_by!(name: product_name) { |model|
        model.stock_amount = Random.rand(1000..10000)
        model.pd_price = Random.rand(0..9.99).round(2)
      }
    end
    user_product
  end
end

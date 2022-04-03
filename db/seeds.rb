
user0 = User.find_or_create_by!(id: 0, name: 'System')
product1 = user0.products.find_or_create_by!(name: 'Apple 1kg') { |model|
  model.stock_amount = 10000
  model.pd_price = 9.9
}
product2 = user0.products.find_or_create_by!(name: 'Banana 500g') { |model|
  model.stock_amount = 10000
  model.pd_price = 4.99
}

order1 = user0.orders.find_or_create_by!(product_id: product1.id) { |model|
  model.pd_amount = 1
}
order2 = user0.orders.find_or_create_by!(product_id: product2.id) { |model|
  model.pd_amount = 2
}

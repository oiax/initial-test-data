include InitialTestData::Utilities

u = fetch(:user, :dave)
p = fetch(:product, :a)
Order.create!(user: u, product: p)
Order.create!(user: u, product: p)

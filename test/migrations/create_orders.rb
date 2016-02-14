class CreateOrders < ActiveRecord::Migration
  def change
    create_table(:orders) do |t|
      t.references :user
      t.references :product
      t.integer :quantity
    end
  end
end

CreateOrders.migrate(:up)

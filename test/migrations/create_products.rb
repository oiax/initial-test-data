class CreateProducts < ActiveRecord::Migration
  def change
    create_table(:products) do |t|
      t.string :name
      t.integer :price
    end
  end
end

CreateProducts.migrate(:up)

class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.string     :status
      t.text       :details
      t.integer    :quantity
      t.references :product
      t.references :seller
      t.references :supplier
      t.references :seller_order
      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end

class CreateProductOrders < ActiveRecord::Migration
  def self.up
    create_table :product_orders do |t|
      t.integer    :quantity,        :null => false
      t.references :product,         :null => false
      t.references :supplier,        :null => false
      t.references :seller_order,    :null => false
      t.string     :tracking_number
      t.datetime   :accepted_at
      t.datetime   :completed_at
      t.timestamps
    end
    add_index :product_orders, [:product_id, :seller_order_id], :unique => true
  end

  def self.down
    drop_table :product_orders
  end
end


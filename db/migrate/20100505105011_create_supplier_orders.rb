class CreateSupplierOrders < ActiveRecord::Migration
  def self.up
    create_table :supplier_orders do |t|
      t.integer    :quantity,       :null => false
      t.references :product,        :null => false
      t.references :supplier,       :null => false
      t.references :seller_order,   :null => false
      t.datetime   :accepted_at
      t.datetime   :rejected_at
      t.datetime   :completed_at
      t.timestamps
    end
    add_index :supplier_orders, [:product_id, :seller_order_id], :unique => true
  end

  def self.down
    drop_table :supplier_orders
  end
end


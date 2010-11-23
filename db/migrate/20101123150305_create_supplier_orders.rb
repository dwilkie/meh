class CreateSupplierOrders < ActiveRecord::Migration
  def self.up
    create_table :supplier_orders do |t|
      t.references :supplier,        :null => false
      t.references :seller_order,    :null => false
      t.string     :tracking_number
      t.datetime   :completed_at
      t.timestamps
    end
    add_index :supplier_orders, [:supplier_id, :seller_order_id], :unique => true
  end

  def self.down
    drop_table :supplier_orders
  end
end


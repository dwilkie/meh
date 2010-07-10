class CreateSupplierOrders < ActiveRecord::Migration
  def self.up
    create_table :supplier_orders do |t|
      t.string     :status,         :null => false
      t.integer    :quantity,       :null => false
      t.references :product,        :null => false
      t.references :supplier,       :null => false
      t.references :seller_order,   :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :supplier_orders
  end
end


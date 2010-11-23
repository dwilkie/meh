class CreateSupplierPayments < ActiveRecord::Migration
  def self.up
    create_table :supplier_payments do |t|
      t.integer     :cents,   :default => 0, :null => false
      t.string      :currency,               :null => false
      t.text        :payment_response
      t.references  :supplier,               :null => false
      t.references  :seller,                 :null => false
      t.references  :product_order,         :null => false
      t.references  :notification,           :polymorphic => true
      t.timestamps
    end
    add_index :supplier_payments, :product_order_id, :unique => true
  end

  def self.down
    drop_table :supplier_payments
  end
end


class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.integer     :cents,   :default => 0, :null => false
      t.string      :currency,               :null => false
      t.references  :supplier,               :null => false
      t.references  :seller,                 :null => false
      t.references  :supplier_order,         :null => false
      t.timestamps
    end
    add_index :payments, :supplier_order_id, :unique => true
  end

  def self.down
    drop_table :payments
  end
end


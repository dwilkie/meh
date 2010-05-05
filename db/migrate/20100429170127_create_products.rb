class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.integer     :external_id, :null => false
      t.integer     :cents,       :null => false
      t.references  :supplier,    :null => false
      t.references  :seller,      :null => false
      t.timestamps
    end
    # A supplier cannot have more than one product with the same external id
    add_index :products, [:external_id, :supplier_id], :unique => true
    # A seller cannot have more than one product with the same external id
    add_index :products, [:external_id, :seller_id], :unique => true
  end

  def self.down
    drop_table :products
  end
end


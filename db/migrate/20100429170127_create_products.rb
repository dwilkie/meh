class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string      :external_id,            :null => false
      t.string      :verification_code,      :null => false
      t.integer     :cents,   :default => 0, :null => false
      t.string      :currency
      t.references  :supplier,               :null => false
      t.references  :seller,                 :null => false
      t.timestamps
    end
    # A seller cannot have more than one product with the same external id
    add_index :products, [:external_id, :seller_id], :unique => true
    # A seller cannot have more than one product with teh same verification code
    add_index :products, [:verification_code, :seller_id], :unique => true
  end

  def self.down
    drop_table :products
  end
end


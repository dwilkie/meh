class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string      :item_number,            :null => false
      #t.string      :item_name
      t.string      :verification_code,      :null => false
      t.integer     :cents,   :default => 0, :null => false
      t.string      :currency
      t.references  :supplier,               :null => false
      t.references  :seller,                 :null => false
      t.timestamps
    end
    # A seller cannot have more than one product with the same item number
    add_index :products, [:item_number, :seller_id], :unique => true
    # A seller cannot have more than one product with the same verification code
    add_index :products, [:verification_code, :seller_id], :unique => true
  end

  def self.down
    drop_table :products
  end
end


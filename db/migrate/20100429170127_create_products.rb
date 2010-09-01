class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string      :number,                 :null => false
      t.string      :name,                   :null => false
      t.string      :verification_code
      t.integer     :cents,   :default => 0, :null => false
      t.string      :currency
      t.references  :supplier,               :null => false
      t.references  :seller,                 :null => false
      t.timestamps
    end
    # A seller cannot have more than one product with the same number
    add_index :products, [:number, :seller_id], :unique => true
    # A seller cannot have more than one product with the same name
    add_index :products, [:name, :seller_id], :unique => true
  end

  def self.down
    drop_table :products
  end
end


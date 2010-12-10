class CreatePartnerships < ActiveRecord::Migration
  def self.up
    create_table :partnerships do |t|
      t.references :seller,           :null => false
      t.references :supplier,         :null => false
      t.datetime   :confirmed_at
      t.timestamps
    end
    add_index :partnerships, [:seller_id, :supplier_id], :unique => true
  end

  def self.down
    drop_table :partnerships
  end
end


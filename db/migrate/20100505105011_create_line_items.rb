class CreateLineItems < ActiveRecord::Migration
  def self.up
    create_table :line_items do |t|
      t.integer    :quantity,             :null => false
      t.references :product,              :null => false
      t.references :supplier,             :null => false
      t.references :seller_order,         :null => false
      t.references :supplier_order,       :null => false
      t.integer    :seller_order_index,   :null => false
      t.integer    :supplier_order_index, :null => false
      t.datetime   :confirmed_at
      t.timestamps
    end
    add_index :line_items, [:product_id, :seller_order_id],   :unique => true
    add_index :line_items, [:product_id, :supplier_order_id], :unique => true
    add_index :line_items, [:seller_order_index, :seller_order_id], :unique => true
    add_index :line_items, [:supplier_order_index, :supplier_order_id], :unique => true
  end

  def self.down
    drop_table :line_items
  end
end


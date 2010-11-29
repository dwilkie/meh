class CreateLineItems < ActiveRecord::Migration
  def self.up
    create_table :line_items do |t|
      t.integer    :quantity,        :null => false
      t.references :product,         :null => false
      t.references :supplier,        :null => false
      t.references :supplier_order,  :null => false
      t.datetime   :confirmed_at
      t.timestamps
    end
    add_index :line_items, [:product_id, :supplier_order_id], :unique => true
  end

  def self.down
    drop_table :line_items
  end
end


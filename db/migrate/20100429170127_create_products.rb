class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string      :external_id
      t.integer     :cents, :null => false
      t.timestamps
     end
    add_index :products, :external_id, :unique => true
  end

  def self.down
    drop_table :products
  end
end


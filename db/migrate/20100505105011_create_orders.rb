class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.string     :state
      t.text       :details
      t.references :product, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end

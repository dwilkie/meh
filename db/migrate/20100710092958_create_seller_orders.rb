class CreateSellerOrders < ActiveRecord::Migration
  def self.up
    create_table :seller_orders do |t|
      t.references :order_notification, :polymorphic => true, :null => false
      t.references :seller, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :seller_orders
  end
end


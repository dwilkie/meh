class CreateOrderSimulations < ActiveRecord::Migration
  def self.up
    create_table :order_simulations do |t|
      t.text :params,       :null => false
      t.references :seller, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :order_simulations
  end
end


class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table   :notifications do |t|
      t.string     :event,       :null => false
      t.string     :for,         :null => false
      t.string     :purpose,     :null => false
      t.text       :message
      t.boolean    :enabled,      :null => false
      t.boolean    :should_send,  :null => false
      t.references :seller,       :null => false
      t.references :supplier
      t.references :product
      t.timestamps
    end
    add_index(
      :notifications,
      [:seller_id, :product_id, :purpose, :event, :for], :unique => true
    )
    add_index(
      :notifications,
      [:seller_id, :supplier_id, :purpose, :event, :for], :unique => true
    )
  end

  def self.down
    drop_table :notifications
  end
end


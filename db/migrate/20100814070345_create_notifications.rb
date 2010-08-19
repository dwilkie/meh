class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table   :notifications do |t|
      t.string     :event,    :null => false
      t.string     :for,      :null => false
      t.text       :message,  :null => false
      t.references :seller,   :null => false
      t.references :supplier
      t.references :product
      t.timestamps
    end
  end

  def self.down
    drop_table :notifications
  end
end


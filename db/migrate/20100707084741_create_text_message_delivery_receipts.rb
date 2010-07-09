class CreateTextMessageDeliveryReceipts < ActiveRecord::Migration
  def self.up
    create_table :text_message_delivery_receipts do |t|
      t.string      :status
      t.text        :params,                :null => false
      t.references  :outgoing_text_message, :null => false
      t.timestamps
    end
    add_index :text_message_delivery_receipts, :params, :unique => true
  end

  def self.down
    drop_table :text_message_delivery_receipts
  end
end


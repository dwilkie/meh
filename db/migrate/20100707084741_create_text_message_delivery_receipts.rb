class CreateTextMessageDeliveryReceipts < ActiveRecord::Migration
  def self.up
    create_table :text_message_delivery_receipts do |t|
      t.string      :status
      t.text        :params
      t.references  :outgoing_text_message, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :text_message_delivery_receipts
  end
end


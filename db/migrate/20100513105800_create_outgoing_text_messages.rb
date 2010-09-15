class CreateOutgoingTextMessages < ActiveRecord::Migration
  def self.up
    create_table :outgoing_text_messages do |t|
      t.string     :body
      t.string     :gateway_response
      t.string     :gateway_message_id
      t.references :mobile_number, :null => false
      t.datetime   :sent_at
      t.timestamps
    end
    add_index :outgoing_text_messages, :gateway_message_id, :unique => true
  end

  def self.down
    drop_table :outgoing_text_messages
  end
end


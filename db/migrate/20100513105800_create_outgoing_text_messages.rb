class CreateOutgoingTextMessages < ActiveRecord::Migration
  def self.up
    create_table :outgoing_text_messages do |t|
      t.string     :body
      t.string     :gateway_response
      t.string     :gateway_message_id
      t.string     :from
      t.references :smsable, :polymorphic => true, :null => false
      t.timestamps
    end
    add_index :outgoing_text_messages, :gateway_message_id
  end

  def self.down
    drop_table :outgoing_text_messages
  end
end


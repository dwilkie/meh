class CreateIncomingTextMessages < ActiveRecord::Migration
  def self.up
    create_table :incoming_text_messages do |t|
      t.string   :originator,        :null => false
      t.string   :message_id,        :null => false
      t.text     :params
      t.references :smsable, :polymorphic => true, :null => false
      t.references :conversation
      t.timestamps
    end
    add_index :incoming_text_messages, :message_id, :unique => true
  end

  def self.down
    drop_table :incoming_text_messages
  end
end


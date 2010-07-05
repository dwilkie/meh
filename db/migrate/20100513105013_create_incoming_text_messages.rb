class CreateIncomingTextMessages < ActiveRecord::Migration
  def self.up
    create_table :incoming_text_messages do |t|
      t.string   :from,        :null => false
      t.text     :params
      t.references :smsable, :polymorphic => true
      t.timestamps
    end
    add_index :incoming_text_messages, :params, :unique => true
  end

  def self.down
    drop_table :incoming_text_messages
  end
end


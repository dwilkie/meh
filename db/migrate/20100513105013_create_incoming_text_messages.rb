class CreateIncomingTextMessages < ActiveRecord::Migration
  def self.up
    create_table :incoming_text_messages do |t|
      t.string     :from,        :null => false
      t.text       :params
      t.references :mobile_number, :null => false
      t.timestamps
    end
    add_index :incoming_text_messages, :params, :unique => true
  end

  def self.down
    drop_table :incoming_text_messages
  end
end


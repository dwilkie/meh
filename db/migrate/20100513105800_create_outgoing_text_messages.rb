class CreateOutgoingTextMessages < ActiveRecord::Migration
  def self.up
    create_table :outgoing_text_messages do |t|
      t.string     :message,     :null => false
      t.text       :params
      t.references :smsable, :polymorphic => true, :null => false
      t.references :conversation
      t.timestamps
    end
  end

  def self.down
    drop_table :outgoing_text_messages
  end
end


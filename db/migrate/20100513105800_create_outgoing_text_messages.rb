class CreateOutgoingTextMessages < ActiveRecord::Migration
  def self.up
    create_table :outgoing_text_messages do |t|
      t.string     :body
      t.string     :gateway_response
      t.string     :from
      t.references :smsable, :polymorphic => true, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :outgoing_text_messages
  end
end


class CreatePaypalAuthentications < ActiveRecord::Migration
  def self.up
    create_table :paypal_authentications do |t|
      t.text       :params
      t.string     :token
      t.timestamps
    end
    add_index :paypal_authentications, :token, :unique => true
  end

  def self.down
    drop_table :paypal_authentications
  end
end


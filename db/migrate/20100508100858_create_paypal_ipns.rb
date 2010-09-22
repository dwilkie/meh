class CreatePaypalIpns < ActiveRecord::Migration
  def self.up
    create_table :paypal_ipns do |t|
      t.text         :params,         :null => false
      t.string       :transaction_id, :null => false
      t.boolean      :fraudulent
      t.datetime     :verified_at
      t.timestamps
    end
    add_index :paypal_ipns, :transaction_id, :unique => true
  end

  def self.down
    drop_table :paypal_ipns
  end
end


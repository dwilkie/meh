class CreatePaymentRequests < ActiveRecord::Migration
  def self.up
    create_table    :payment_requests do |t|
      t.string      :application_uri, :null => false
      t.references  :payment, :null => false
      t.text        :params,  :null => false
      t.integer     :remote_id
      t.datetime    :answered_at
      t.datetime    :verified_at
      t.boolean     :fraudulent
      t.timestamps
    end
    add_index :payment_requests, :payment_id, :unique => true
  end

  def self.down
    drop_table :payment_requests
  end
end


class CreatePaymentRequests < ActiveRecord::Migration
  def self.up
    create_table    :payment_requests do |t|
      t.string      :application_uri, :null => false
      t.string      :status,  :null => false
      t.references  :payment, :null => false
      t.text        :params,  :null => false
      t.timestamps
    end
    add_index :payment_requests, :payment_id, :unique => true
  end

  def self.down
    drop_table :payment_requests
  end
end

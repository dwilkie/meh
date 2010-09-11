class CreatePaymentRequests < ActiveRecord::Migration
  def self.up
    create_table    :payment_requests do |t|
      t.string      :remote_payment_application_uri, :null => false
      t.references  :payment, :null => false
      t.text        :params,  :null => false
      t.integer     :remote_id
      t.text        :notification
      t.datetime    :notified_at
      t.datetime    :notification_verified_at
      t.datetime    :first_attempt_to_send_to_remote_application_at
      t.string      :failure_error
      t.datetime    :gave_up_at
      t.boolean     :fraudulent
      t.timestamps
    end
    add_index :payment_requests, :payment_id, :unique => true
  end

  def self.down
    drop_table :payment_requests
  end
end


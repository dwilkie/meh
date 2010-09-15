class CreatePaymentRequests < ActiveRecord::Migration
  def self.up
    create_table    :payment_requests do |t|
      t.references  :payment, :null => false
      t.references  :payment_application, :null => false
      t.text        :params,  :null => false
      t.integer     :remote_id
      t.text        :notification
      t.datetime    :first_attempt_to_send_to_remote_application_at
      t.datetime    :remote_application_received_at
      t.datetime    :notified_at
      t.datetime    :notification_verified_at
      t.datetime    :gave_up_at
      t.string      :failure_error
      t.timestamps
    end
    add_index :payment_requests, :payment_id, :unique => true
  end

  def self.down
    drop_table :payment_requests
  end
end


class CreatePaymentApplications < ActiveRecord::Migration
  def self.up
    create_table :payment_applications do |t|
      t.string      :application_url, :null => false
      t.string      :status,          :null => false
      t.references  :seller,          :null => false
      t.timestamps
    end
    add_index :payment_applications, :application_url, :unique => true
    add_index :payment_applications, :seller_id,       :unique => true
  end

  def self.down
    drop_table :payment_applications
  end
end

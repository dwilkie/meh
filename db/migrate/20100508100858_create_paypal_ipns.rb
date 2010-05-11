class CreatePaypalIpns < ActiveRecord::Migration
  def self.up
    create_table :paypal_ipns do |t|
      t.text       :params
      t.string     :payment_status
      t.references :customer_order
      t.timestamps
    end
  end

  def self.down
    drop_table :paypal_ipns
  end
end

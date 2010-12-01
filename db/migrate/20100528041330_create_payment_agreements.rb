class CreatePaymentAgreements < ActiveRecord::Migration
  def self.up
    create_table :payment_agreements do |t|
      t.boolean    :enabled,                :null => false
      t.string     :event
      t.integer    :cents,   :default => 0, :null => false
      t.string     :currency
      t.references :supplier,               :null => false
      t.references :seller,                 :null => false
      t.timestamps
    end
    add_index :payment_agreements,
      [:supplier_id, :seller_id],
      :unique => true
  end

  def self.down
    drop_table :payment_agreements
  end
end


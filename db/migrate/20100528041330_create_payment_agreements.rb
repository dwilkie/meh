class CreatePaymentAgreements < ActiveRecord::Migration
  def self.up
    create_table :payment_agreements do |t|
      t.boolean    :automatic, :default => true,   :null => false
      t.boolean    :confirm,   :default => false,  :null => false
      t.string     :payment_trigger_on_order
      t.references :supplier
      t.references :seller
      t.references :product
      t.timestamps
    end
    # note you will have to change this for postgres
    add_index :payment_agreements, [:supplier_id, :seller_id], :unique => true
    add_index :payment_agreements, :product_id, :unique => true
  end

  def self.down
    drop_table :payment_agreements
  end
end

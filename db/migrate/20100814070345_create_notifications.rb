class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table   :notifications do |t|
      t.string     :event,       :null => false
      t.string     :purpose,     :null => false
      t.string     :for
      t.text       :message
      t.boolean    :enabled,      :null => false
      t.boolean    :should_send,  :null => false
      t.references :seller,       :null => false
      t.references :supplier
      t.references :product
      t.timestamps
    end
    add_index(
      :notifications,
      [:seller_id, :supplier_id, :product_id, :purpose, :event, :for], :unique => true
    )

    #execute "CREATE UNIQUE INDEX user_andor_company_company_key ON user_andor_company (company) WHERE user IS NOT NULL"

    # add indexes to ensure nulls are also considered the same (to complement model)
    # see postrsql unique index documentation
  end

  def self.down
    drop_table :notifications
  end
end


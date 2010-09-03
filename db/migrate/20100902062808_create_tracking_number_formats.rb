class CreateTrackingNumberFormats < ActiveRecord::Migration
  def self.up
    create_table :tracking_number_formats do |t|
      t.string     :format
      t.boolean    :required,     :null => false
      t.references :seller,       :null => false
      t.references :supplier
      t.references :product
      t.timestamps
    end
    add_index(
      :tracking_number_formats,
      [:seller_id, :supplier_id, :product_id], :unique => true
    )
    # add indexes to ensure nulls are also considered the same (to complement model)
    # see postrsql unique index documentation
  end

  def self.down
    drop_table :tracking_number_formats
  end
end


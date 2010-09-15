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
    # name => max length is 64 chars
    add_index(:tracking_number_formats,
      [:seller_id, :supplier_id, :product_id], :unique => true,
      :name => "index_tracking_number_formats_unique"
    )
  end

  def self.down
    drop_table :tracking_number_formats
  end
end


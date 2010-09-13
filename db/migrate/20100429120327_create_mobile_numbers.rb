class CreateMobileNumbers < ActiveRecord::Migration
  def self.up
    create_table :mobile_numbers do |t|
      t.string     :number,               :null => false
      t.datetime   :verified_at
      t.integer    :active
      t.references :user,                 :null => false
      t.timestamps
    end
    add_index :mobile_numbers, :number, :unique => true
  end

  def self.down
    drop_table :mobile_numbers
  end
end


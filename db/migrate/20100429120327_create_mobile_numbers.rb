class CreateMobileNumbers < ActiveRecord::Migration
  def self.up
    create_table :mobile_numbers do |t|
      t.string     :number,               :null => false
      t.datetime   :verified_at
      t.references :user
      t.references :active_user
      t.timestamps
    end
    add_index :mobile_numbers, :number, :unique => true
  end

  def self.down
    drop_table :mobile_numbers
  end
end


class CreateMobileNumbers < ActiveRecord::Migration
  def self.up
    create_table :mobile_numbers do |t|
      t.string     :number,               :limit => 20,                  :null => false
      t.string     :encrypted_password,   :limit => 128, :default => "", :null => false
      t.string     :password_salt,                       :default => "", :null => false
      t.string     :verification_code,                                   :null => false
      t.string     :activation_code
      t.string     :locale
      t.string     :state,                                               :null => false
      t.references :phoneable, :polymorphic => true
      t.timestamps
    end
    add_index :mobile_numbers, :number, :unique => true
  end

  def self.down
    drop_table :mobile_numbers
  end
end


class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.database_authenticatable :null => false
      t.string   :email
      t.recoverable
      t.rememberable
      t.trackable
      t.integer :roles_mask, :default => 0, :null => false
      t.string  :name, :null => false
      t.integer :message_credits, :default => 0, :null => false
      t.references :active_mobile_number
      t.timestamps
    end

    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
    add_index :users, :active_mobile_number_id, :unique => true
  end

  def self.down
    drop_table :users
  end
end


class DeviseCreateSuppliers < ActiveRecord::Migration
  def self.up
    create_table(:suppliers) do |t|
      t.database_authenticatable :null => false
      t.confirmable
      t.recoverable
      t.rememberable
      # t.trackable

      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable

      t.timestamps
    end

    add_index :suppliers, :email,                :unique => true
    add_index :suppliers, :confirmation_token,   :unique => true
    add_index :suppliers, :reset_password_token, :unique => true
    # add_index :suppliers, :unlock_token,         :unique => true
  end

  def self.down
    drop_table :suppliers
  end
end

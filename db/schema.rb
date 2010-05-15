# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100513105800) do

  create_table "conversations", :force => true do |t|
    t.string   "state",      :null => false
    t.string   "with",       :null => false
    t.string   "topic"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "incoming_text_messages", :force => true do |t|
    t.string   "originator",   :null => false
    t.text     "params"
    t.integer  "smsable_id"
    t.string   "smsable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "incoming_text_messages", ["params"], :name => "index_incoming_text_messages_on_params", :unique => true

  create_table "mobile_numbers", :force => true do |t|
    t.string   "number",            :limit => 20, :null => false
    t.string   "verification_code",               :null => false
    t.string   "activation_code"
    t.string   "locale"
    t.string   "state",                           :null => false
    t.integer  "phoneable_id"
    t.string   "phoneable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mobile_numbers", ["number"], :name => "index_mobile_numbers_on_number", :unique => true

  create_table "orders", :force => true do |t|
    t.string   "status"
    t.text     "details"
    t.integer  "quantity"
    t.integer  "product_id"
    t.integer  "seller_id"
    t.integer  "supplier_id"
    t.integer  "seller_order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outgoing_text_messages", :force => true do |t|
    t.string   "message",      :null => false
    t.text     "params"
    t.integer  "smsable_id",   :null => false
    t.string   "smsable_type", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "paypal_ipns", :force => true do |t|
    t.text     "params"
    t.string   "payment_status"
    t.integer  "customer_order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", :force => true do |t|
    t.string   "external_id",       :null => false
    t.string   "verification_code", :null => false
    t.integer  "cents",             :null => false
    t.integer  "supplier_id",       :null => false
    t.integer  "seller_id",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "products", ["external_id", "seller_id"], :name => "index_products_on_external_id_and_seller_id", :unique => true
  add_index "products", ["verification_code", "seller_id"], :name => "index_products_on_verification_code_and_seller_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "roles_mask"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end

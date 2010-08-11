# This file is auto-generated from the current state of the database. Instead 
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your 
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100710092958) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "incoming_text_messages", :force => true do |t|
    t.string   "from",             :null => false
    t.text     "params"
    t.integer  "mobile_number_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "incoming_text_messages", ["params"], :name => "index_incoming_text_messages_on_params", :unique => true

  create_table "mobile_numbers", :force => true do |t|
    t.string   "number",             :limit => 20,                  :null => false
    t.string   "encrypted_password", :limit => 128, :default => "", :null => false
    t.string   "password_salt",                     :default => "", :null => false
    t.string   "verification_code",                                 :null => false
    t.string   "activation_code"
    t.string   "locale"
    t.string   "state",                                             :null => false
    t.integer  "phoneable_id"
    t.string   "phoneable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mobile_numbers", ["number"], :name => "index_mobile_numbers_on_number", :unique => true

  create_table "outgoing_text_messages", :force => true do |t|
    t.string   "body"
    t.string   "gateway_response"
    t.string   "gateway_message_id"
    t.string   "from"
    t.integer  "mobile_number_id",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "outgoing_text_messages", ["gateway_message_id"], :name => "index_outgoing_text_messages_on_gateway_message_id"

  create_table "payment_agreements", :force => true do |t|
    t.boolean  "automatic",                :default => true,  :null => false
    t.boolean  "confirm",                  :default => false, :null => false
    t.string   "payment_trigger_on_order"
    t.integer  "supplier_id"
    t.integer  "seller_id"
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payment_agreements", ["product_id"], :name => "index_payment_agreements_on_product_id", :unique => true
  add_index "payment_agreements", ["supplier_id", "seller_id"], :name => "index_payment_agreements_on_supplier_id_and_seller_id", :unique => true

  create_table "payment_applications", :force => true do |t|
    t.string   "uri",        :null => false
    t.string   "status",     :null => false
    t.integer  "seller_id",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payment_applications", ["seller_id"], :name => "index_payment_applications_on_seller_id", :unique => true
  add_index "payment_applications", ["uri"], :name => "index_payment_applications_on_uri", :unique => true

  create_table "payment_requests", :force => true do |t|
    t.string   "application_uri",          :null => false
    t.integer  "payment_id",               :null => false
    t.text     "params",                   :null => false
    t.integer  "remote_id"
    t.text     "notification"
    t.datetime "notified_at"
    t.datetime "notification_verified_at"
    t.boolean  "fraudulent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payment_requests", ["payment_id"], :name => "index_payment_requests_on_payment_id", :unique => true

  create_table "payments", :force => true do |t|
    t.integer  "cents",             :default => 0, :null => false
    t.string   "currency",                         :null => false
    t.string   "status",                           :null => false
    t.integer  "supplier_id",                      :null => false
    t.integer  "seller_id",                        :null => false
    t.integer  "supplier_order_id",                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payments", ["supplier_order_id"], :name => "index_payments_on_supplier_order_id", :unique => true

  create_table "paypal_ipns", :force => true do |t|
    t.text     "params",         :null => false
    t.string   "transaction_id", :null => false
    t.string   "payment_status"
    t.boolean  "fraudulent"
    t.datetime "verified_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "paypal_ipns", ["transaction_id"], :name => "index_paypal_ipns_on_transaction_id", :unique => true

  create_table "products", :force => true do |t|
    t.string   "item_number",                      :null => false
    t.string   "verification_code",                :null => false
    t.integer  "cents",             :default => 0, :null => false
    t.string   "currency"
    t.integer  "supplier_id",                      :null => false
    t.integer  "seller_id",                        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "products", ["item_number", "seller_id"], :name => "index_products_on_item_number_and_seller_id", :unique => true
  add_index "products", ["verification_code", "seller_id"], :name => "index_products_on_verification_code_and_seller_id", :unique => true

  create_table "seller_orders", :force => true do |t|
    t.integer  "order_notification_id",   :null => false
    t.string   "order_notification_type", :null => false
    t.integer  "seller_id",               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "supplier_orders", :force => true do |t|
    t.string   "status",          :null => false
    t.integer  "quantity",        :null => false
    t.integer  "product_id",      :null => false
    t.integer  "supplier_id",     :null => false
    t.integer  "seller_order_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "supplier_orders", ["product_id", "seller_order_id"], :name => "index_supplier_orders_on_product_id_and_seller_order_id", :unique => true

  create_table "text_message_delivery_receipts", :force => true do |t|
    t.string   "status"
    t.text     "params",                   :null => false
    t.integer  "outgoing_text_message_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "text_message_delivery_receipts", ["params"], :name => "index_text_message_delivery_receipts_on_params", :unique => true

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

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

ActiveRecord::Schema.define(:version => 20101230095841) do

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
    t.text     "params",           :null => false
    t.integer  "mobile_number_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "incoming_text_messages", ["params"], :name => "index_incoming_text_messages_on_params", :unique => true

  create_table "line_items", :force => true do |t|
    t.integer  "quantity",             :null => false
    t.integer  "product_id",           :null => false
    t.integer  "supplier_id",          :null => false
    t.integer  "seller_order_id",      :null => false
    t.integer  "supplier_order_id",    :null => false
    t.integer  "seller_order_index",   :null => false
    t.integer  "supplier_order_index", :null => false
    t.datetime "confirmed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "line_items", ["product_id", "seller_order_id"], :name => "index_line_items_on_product_id_and_seller_order_id", :unique => true
  add_index "line_items", ["product_id", "supplier_order_id"], :name => "index_line_items_on_product_id_and_supplier_order_id", :unique => true
  add_index "line_items", ["seller_order_index", "seller_order_id"], :name => "index_line_items_on_seller_order_index_and_seller_order_id", :unique => true
  add_index "line_items", ["supplier_order_index", "supplier_order_id"], :name => "index_line_items_on_supplier_order_index_and_supplier_order_id", :unique => true

  create_table "mobile_numbers", :force => true do |t|
    t.string   "number",      :null => false
    t.datetime "verified_at"
    t.integer  "active"
    t.integer  "user_id",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mobile_numbers", ["number"], :name => "index_mobile_numbers_on_number", :unique => true

  create_table "notifications", :force => true do |t|
    t.string   "event",       :null => false
    t.string   "purpose",     :null => false
    t.string   "for"
    t.text     "message"
    t.boolean  "enabled",     :null => false
    t.boolean  "should_send", :null => false
    t.integer  "seller_id",   :null => false
    t.integer  "supplier_id"
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notifications", ["seller_id", "supplier_id", "product_id", "purpose", "event", "for"], :name => "index_notifications_unique", :unique => true

  create_table "order_simulations", :force => true do |t|
    t.text     "params",     :null => false
    t.integer  "seller_id",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outgoing_text_messages", :force => true do |t|
    t.text     "body"
    t.string   "gateway_response"
    t.string   "gateway_message_id"
    t.integer  "mobile_number_id",                             :null => false
    t.integer  "payer_id",                                     :null => false
    t.integer  "credits",                       :default => 0, :null => false
    t.datetime "sent_at"
    t.datetime "last_failed_to_send_at"
    t.datetime "permanently_failed_to_send_at"
    t.datetime "queued_for_sending_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "outgoing_text_messages", ["gateway_message_id"], :name => "index_outgoing_text_messages_on_gateway_message_id", :unique => true

  create_table "partnerships", :force => true do |t|
    t.integer  "seller_id",    :null => false
    t.integer  "supplier_id",  :null => false
    t.datetime "confirmed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "partnerships", ["seller_id", "supplier_id"], :name => "index_partnerships_on_seller_id_and_supplier_id", :unique => true

  create_table "payment_agreements", :force => true do |t|
    t.boolean  "enabled",                    :null => false
    t.string   "event"
    t.integer  "cents",       :default => 0, :null => false
    t.string   "currency"
    t.integer  "supplier_id",                :null => false
    t.integer  "seller_id",                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payment_agreements", ["supplier_id", "seller_id"], :name => "index_payment_agreements_on_supplier_id_and_seller_id", :unique => true

  create_table "paypal_authentications", :force => true do |t|
    t.text     "params"
    t.text     "user_details"
    t.string   "token"
    t.datetime "queued_for_confirmation_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "paypal_authentications", ["token"], :name => "index_paypal_authentications_on_token", :unique => true

  create_table "paypal_ipns", :force => true do |t|
    t.text     "params",         :null => false
    t.string   "transaction_id", :null => false
    t.string   "payment_status"
    t.datetime "fraudulent_at"
    t.datetime "verified_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "paypal_ipns", ["transaction_id"], :name => "index_paypal_ipns_on_transaction_id", :unique => true

  create_table "products", :force => true do |t|
    t.string   "number",                           :null => false
    t.string   "name",                             :null => false
    t.string   "price"
    t.string   "verification_code"
    t.integer  "cents",             :default => 0, :null => false
    t.string   "currency"
    t.integer  "partnership_id"
    t.integer  "seller_id",                        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "products", ["name", "seller_id"], :name => "index_products_on_name_and_seller_id", :unique => true
  add_index "products", ["number", "seller_id"], :name => "index_products_on_number_and_seller_id", :unique => true

  create_table "seller_orders", :force => true do |t|
    t.integer  "order_notification_id",   :null => false
    t.string   "order_notification_type", :null => false
    t.integer  "seller_id",               :null => false
    t.datetime "confirmed_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "supplier_orders", :force => true do |t|
    t.integer  "supplier_id",          :null => false
    t.integer  "seller_order_id",      :null => false
    t.integer  "number_of_line_items", :null => false
    t.string   "tracking_number"
    t.datetime "confirmed_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "supplier_orders", ["supplier_id", "seller_order_id"], :name => "index_supplier_orders_on_supplier_id_and_seller_order_id", :unique => true

  create_table "supplier_payments", :force => true do |t|
    t.integer  "cents",             :default => 0, :null => false
    t.string   "currency",                         :null => false
    t.text     "payment_response"
    t.integer  "supplier_id",                      :null => false
    t.integer  "seller_id",                        :null => false
    t.integer  "supplier_order_id",                :null => false
    t.integer  "notification_id"
    t.string   "notification_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "supplier_payments", ["supplier_order_id"], :name => "index_supplier_payments_on_supplier_order_id", :unique => true

  create_table "text_message_delivery_receipts", :force => true do |t|
    t.string   "status"
    t.text     "params",                   :null => false
    t.integer  "outgoing_text_message_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "text_message_delivery_receipts", ["params"], :name => "index_text_message_delivery_receipts_on_params", :unique => true

  create_table "tracking_number_formats", :force => true do |t|
    t.string   "format"
    t.boolean  "required",    :null => false
    t.integer  "seller_id",   :null => false
    t.integer  "supplier_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tracking_number_formats", ["seller_id", "supplier_id"], :name => "index_tracking_number_formats_on_seller_id_and_supplier_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "roles_mask",                          :default => 0,  :null => false
    t.string   "name",                                                :null => false
    t.integer  "message_credits",                     :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end

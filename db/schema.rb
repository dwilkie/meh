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

ActiveRecord::Schema.define(:version => 20100429120327) do

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

  create_table "suppliers", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "suppliers", ["email"], :name => "index_suppliers_on_email", :unique => true
  add_index "suppliers", ["reset_password_token"], :name => "index_suppliers_on_reset_password_token", :unique => true

end

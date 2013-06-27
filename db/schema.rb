# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20130627075019) do

  create_table "comparisons", :force => true do |t|
    t.string   "clients"
    t.string   "reqs_per_second"
    t.string   "strategies"
    t.integer  "iterations"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "amount_of_tests"
  end

  create_table "simulations", :force => true do |t|
    t.datetime "ended_at"
    t.text     "content"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.float    "percentage"
    t.string   "strategy"
    t.integer  "clients"
    t.integer  "iterations"
    t.float    "reqs_per_second"
    t.boolean  "hidden",          :default => false
  end

end

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

ActiveRecord::Schema.define(:version => 20140314150855) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "fb_stats", :force => true do |t|
    t.integer  "project_id"
    t.text     "posts"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "start_date"
    t.string   "forum_start_date"
    t.text     "forum_stats"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.text     "describtion"
    t.text     "bugLists"
    t.text     "gitRepositories"
    t.text     "mailLists"
    t.text     "ircChannels"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

end

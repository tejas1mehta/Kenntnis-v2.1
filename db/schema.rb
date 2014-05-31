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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140530035919) do

  create_table "answers", force: true do |t|
    t.text     "main_answer",             null: false
    t.integer  "question_id",             null: false
    t.integer  "author_id"
    t.integer  "upvotes",     default: 0
    t.integer  "downvotes",   default: 0
    t.integer  "numViews",    default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answers", ["author_id"], name: "index_answers_on_author_id"
  add_index "answers", ["created_at"], name: "index_answers_on_created_at"
  add_index "answers", ["question_id"], name: "index_answers_on_question_id"

  create_table "comments", force: true do |t|
    t.text     "comment_body",      null: false
    t.integer  "author_id"
    t.integer  "upvotes"
    t.integer  "downvotes"
    t.integer  "parent_comment_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "followings", force: true do |t|
    t.integer  "f_id",            null: false
    t.integer  "followable_id"
    t.string   "followable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "followings", ["created_at"], name: "index_followings_on_created_at"
  add_index "followings", ["followable_id", "followable_type", "f_id"], name: "index_followings_on_followable_id_and_followable_type_and_f_id", unique: true

  create_table "messages", force: true do |t|
    t.text     "message_body"
    t.string   "subject"
    t.integer  "sent_by_id",                        null: false
    t.integer  "sent_to_id",                        null: false
    t.integer  "parent_message_id"
    t.boolean  "viewed",            default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["sent_by_id"], name: "index_messages_on_sent_by_id"
  add_index "messages", ["sent_to_id"], name: "index_messages_on_sent_to_id"

  create_table "notifications", force: true do |t|
    t.text     "notification_body"
    t.integer  "sent_by_id"
    t.integer  "sent_to_id",                        null: false
    t.integer  "about_object_id"
    t.string   "about_object_type"
    t.boolean  "viewed",            default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "questions", force: true do |t|
    t.string   "main_question",             null: false
    t.text     "description"
    t.integer  "author_id"
    t.integer  "upvotes",       default: 0
    t.integer  "downvotes",     default: 0
    t.integer  "numViews",      default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "questions", ["author_id"], name: "index_questions_on_author_id"
  add_index "questions", ["created_at"], name: "index_questions_on_created_at"

  create_table "topic_question_joins", force: true do |t|
    t.integer  "topic_id",    null: false
    t.integer  "question_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "topic_question_joins", ["question_id"], name: "index_topic_question_joins_on_question_id"
  add_index "topic_question_joins", ["topic_id"], name: "index_topic_question_joins_on_topic_id"

  create_table "topics", force: true do |t|
    t.string   "title",                   null: false
    t.integer  "author_id"
    t.text     "description"
    t.integer  "numViews",    default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "topics", ["created_at"], name: "index_topics_on_created_at"

  create_table "upvotes", force: true do |t|
    t.integer  "user_id",         null: false
    t.integer  "upvoteable_id"
    t.string   "upvoteable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "upvotes", ["created_at"], name: "index_upvotes_on_created_at"
  add_index "upvotes", ["user_id", "upvoteable_id", "upvoteable_type"], name: "index_upvotes_on_user_id_and_upvoteable_id_and_upvoteable_type", unique: true

  create_table "user_question_a2as", force: true do |t|
    t.integer  "relevant_user_id", null: false
    t.integer  "question_id",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_question_a2as", ["question_id"], name: "index_user_question_a2as_on_question_id"

  create_table "users", force: true do |t|
    t.string   "session_token",                    null: false
    t.string   "email",                            null: false
    t.string   "password_digest",                  null: false
    t.string   "name",                             null: false
    t.text     "about"
    t.string   "location"
    t.text     "education"
    t.text     "employment"
    t.integer  "credits",          default: 500
    t.integer  "num_credits_ans",  default: 0
    t.boolean  "activated",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "activation_token"
  end

  add_index "users", ["created_at"], name: "index_users_on_created_at"
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["session_token"], name: "index_users_on_session_token"

end

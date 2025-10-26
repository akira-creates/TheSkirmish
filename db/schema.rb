# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_10_26_073524) do
  create_table "brackets", force: :cascade do |t|
    t.integer "round"
    t.integer "position"
    t.integer "fighter1_id", null: false
    t.integer "fighter2_id", null: false
    t.integer "winner_id", null: false
    t.boolean "completed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fighter1_id"], name: "index_brackets_on_fighter1_id"
    t.index ["fighter2_id"], name: "index_brackets_on_fighter2_id"
    t.index ["winner_id"], name: "index_brackets_on_winner_id"
  end

  create_table "fighters", force: :cascade do |t|
    t.string "name"
    t.string "club"
    t.integer "wins"
    t.integer "losses"
    t.integer "points"
    t.integer "points_against"
    t.boolean "eliminated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "matches", force: :cascade do |t|
    t.integer "pool_id", null: false
    t.integer "fighter1_id", null: false
    t.integer "fighter2_id", null: false
    t.integer "winner_id", null: false
    t.string "status"
    t.string "fighter1_main"
    t.string "fighter1_offhand"
    t.string "fighter1_debuff"
    t.string "fighter2_main"
    t.string "fighter2_offhand"
    t.string "fighter2_debuff"
    t.integer "fighter1_points"
    t.integer "fighter2_points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fighter1_id"], name: "index_matches_on_fighter1_id"
    t.index ["fighter2_id"], name: "index_matches_on_fighter2_id"
    t.index ["pool_id"], name: "index_matches_on_pool_id"
    t.index ["winner_id"], name: "index_matches_on_winner_id"
  end

  create_table "pool_fighters", force: :cascade do |t|
    t.integer "pool_id", null: false
    t.integer "fighter_id", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fighter_id"], name: "index_pool_fighters_on_fighter_id"
    t.index ["pool_id"], name: "index_pool_fighters_on_pool_id"
  end

  create_table "pools", force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.boolean "completed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "brackets", "fighter1s"
  add_foreign_key "brackets", "fighter2s"
  add_foreign_key "brackets", "winners"
  add_foreign_key "matches", "fighter1s"
  add_foreign_key "matches", "fighter2s"
  add_foreign_key "matches", "pools"
  add_foreign_key "matches", "winners"
  add_foreign_key "pool_fighters", "fighters"
  add_foreign_key "pool_fighters", "pools"
end

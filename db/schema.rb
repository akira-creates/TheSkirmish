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

ActiveRecord::Schema[8.0].define(version: 2025_10_27_073356) do
  create_table "brackets", force: :cascade do |t|
    t.integer "round"
    t.integer "position"
    t.integer "fighter1_id", null: false
    t.integer "fighter2_id", null: false
    t.integer "winner_id"
    t.boolean "completed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bracket_type"
    t.integer "loser_id"
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
    t.integer "winner_id"
    t.string "status"
    t.integer "fighter1_main_id"
    t.integer "fighter1_offhand_id"
    t.string "fighter1_debuff"
    t.integer "fighter2_main_id"
    t.integer "fighter2_offhand_id"
    t.string "fighter2_debuff"
    t.integer "fighter1_points"
    t.integer "fighter2_points"
    t.integer "duration"
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
    t.integer "pool_size"
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

  create_table "weapons", force: :cascade do |t|
    t.string "name"
    t.string "weapon_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "brackets", "fighters", column: "fighter1_id"
  add_foreign_key "brackets", "fighters", column: "fighter2_id"
  add_foreign_key "brackets", "fighters", column: "winner_id"
  add_foreign_key "matches", "fighters", column: "fighter1_id"
  add_foreign_key "matches", "fighters", column: "fighter2_id"
  add_foreign_key "matches", "fighters", column: "winner_id"
  add_foreign_key "matches", "weapons", column: "fighter1_main_id"
  add_foreign_key "matches", "weapons", column: "fighter1_offhand_id"
  add_foreign_key "matches", "weapons", column: "fighter2_main_id"
  add_foreign_key "matches", "weapons", column: "fighter2_offhand_id"
end

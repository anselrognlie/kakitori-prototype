# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_17_165229) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "kanjis", force: :cascade do |t|
    t.string "glyph", default: "", null: false
    t.string "gloss", default: "", null: false
    t.string "mnemonic", default: "", null: false
    t.string "readings", default: "", null: false
    t.string "meanings", default: "", null: false
    t.integer "joyo_level_id", default: 0, null: false
    t.integer "jlpt_level_id", default: 0, null: false
    t.integer "grade", default: 0, null: false
    t.integer "strokes", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_settings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "key", null: false
    t.string "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id", "key"], name: "index_user_settings_on_user_id_and_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.datetime "last_activity", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "user_settings", "users", on_delete: :cascade
end

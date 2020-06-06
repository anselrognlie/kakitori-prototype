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

ActiveRecord::Schema.define(version: 2020_06_05_224932) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "joyo_glosses", force: :cascade do |t|
    t.string "gloss", null: false
    t.string "normalized", null: false
    t.bigint "kanjidic_main_id"
    t.index ["kanjidic_main_id"], name: "index_joyo_glosses_on_kanjidic_main_id"
  end

  create_table "joyo_imports", force: :cascade do |t|
    t.integer "joyo_level", default: 0, null: false
    t.integer "jlpt_level", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "kanjidic_main_id"
    t.index ["kanjidic_main_id"], name: "index_joyo_imports_on_kanjidic_main_id"
  end

  create_table "kanjidic_mains", force: :cascade do |t|
    t.string "glyph", null: false
    t.integer "grade", default: 0, null: false
    t.integer "strokes", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["glyph"], name: "index_kanjidic_mains_on_glyph", unique: true
  end

  create_table "kanjidic_meanings", force: :cascade do |t|
    t.string "meaning", null: false
    t.string "normalized", null: false
    t.bigint "kanjidic_main_id"
    t.index ["kanjidic_main_id"], name: "index_kanjidic_meanings_on_kanjidic_main_id"
  end

  create_table "kanjidic_readings", force: :cascade do |t|
    t.string "reading", null: false
    t.string "normalized", null: false
    t.integer "type", null: false
    t.bigint "kanjidic_main_id"
    t.index ["kanjidic_main_id"], name: "index_kanjidic_readings_on_kanjidic_main_id"
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

  add_foreign_key "joyo_glosses", "kanjidic_mains"
  add_foreign_key "joyo_imports", "kanjidic_mains"
  add_foreign_key "kanjidic_meanings", "kanjidic_mains"
  add_foreign_key "kanjidic_readings", "kanjidic_mains"
  add_foreign_key "user_settings", "users", on_delete: :cascade
end

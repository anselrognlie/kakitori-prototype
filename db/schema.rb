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

ActiveRecord::Schema.define(version: 2020_08_03_003713) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "jlpt_imports", force: :cascade do |t|
    t.string "glyph", null: false
    t.string "level", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "kanjidic_import_meanings", force: :cascade do |t|
    t.string "glyph", null: false
    t.string "meaning", null: false
    t.string "normalized", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["glyph"], name: "index_kanjidic_import_meanings_on_glyph"
  end

  create_table "kanjidic_import_readings", force: :cascade do |t|
    t.string "glyph", null: false
    t.string "reading", null: false
    t.string "normalized", null: false
    t.string "type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["glyph"], name: "index_kanjidic_import_readings_on_glyph"
  end

  create_table "kanjidic_imports", force: :cascade do |t|
    t.string "glyph", null: false
    t.string "codepoint", null: false
    t.integer "grade"
    t.integer "strokes", null: false
    t.integer "frequency"
    t.integer "jlpt_old"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["glyph"], name: "index_kanjidic_imports_on_glyph", unique: true
  end

  create_table "kanken_import_glosses", force: :cascade do |t|
    t.string "glyph", null: false
    t.string "gloss", null: false
    t.string "normalized", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["glyph"], name: "index_kanken_import_glosses_on_glyph"
  end

  create_table "kanken_imports", force: :cascade do |t|
    t.string "glyph", null: false
    t.string "level", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["glyph"], name: "index_kanken_imports_on_glyph", unique: true
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

  add_foreign_key "kanjidic_import_meanings", "kanjidic_imports", column: "glyph", primary_key: "glyph"
  add_foreign_key "kanjidic_import_readings", "kanjidic_imports", column: "glyph", primary_key: "glyph"
  add_foreign_key "kanken_import_glosses", "kanken_imports", column: "glyph", primary_key: "glyph"
  add_foreign_key "user_settings", "users", on_delete: :cascade
end

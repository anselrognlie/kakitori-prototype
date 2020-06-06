class CreateJoyoImports < ActiveRecord::Migration[6.0]
  def change
    create_table :joyo_imports do |t|
      t.integer :joyo_level, null: false, default: 0
      t.integer :jlpt_level, null: false, default: 0
      t.timestamps
    end

    create_table :joyo_glosses do |t|
      t.string :gloss, null: false
      t.string :normalized, null: false
    end

    add_reference :joyo_imports, :kanjidic_main, foreign_key: true
    add_reference :joyo_glosses, :kanjidic_main, foreign_key: true
  end
end

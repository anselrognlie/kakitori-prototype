class CreateJlptLevels < ActiveRecord::Migration[6.0]
  def change
    create_table :jlpt_levels do |t|
      t.string :label, null: false, default: 'invalid'
      t.timestamps
    end
  end
end

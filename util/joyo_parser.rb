# frozen_string_literal: true

require_relative 'joyo_document'

document = JoyoDocument.new

records = []
document.read('db/seed_data/joyo.csv')[1..10].each do |r|
  records << {
    glyph: r.glyph,
    gloss: r.gloss,
    joyo_level_id: r.joyo,
    jlpt_level_id: r.jlpt
  }
end

puts "completed with #{records.count} records."
puts records

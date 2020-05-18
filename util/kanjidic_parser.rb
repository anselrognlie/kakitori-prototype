# frozen_string_literal: true

require_relative 'kanjidic_document'

document = KanjidicDocument.new
parser = Nokogiri::XML::SAX::Parser.new(document)
parser.parse(File.open('db/seed_data/kanjidic2.xml'))

records = []
document.records[1..10].each do |r|
  records << {
    glyph: r.literal,
    meanings: r.meanings.join(', '),
    readings: r.readings.join(', '),
    grade: r.grade,
    strokes: r.stroke_count
  }
end

puts "completed with #{records.count} records."

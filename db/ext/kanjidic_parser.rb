# frozen_string_literal: true

require_relative 'kanjidic_document'

module KTL
  module_function

  # rubocop: disable Metrics/MethodLength, Metrics/AbcSize
  def main
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
  end
  # rubocop: enable Metrics/MethodLength, Metrics/AbcSize
end

KTL.main

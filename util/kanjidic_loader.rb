# frozen_string_literal: true

require_relative 'kanjidic_document'

# rubocop: disable Metrics/AbcSize, Metrics/MethodLength
def load_kanjidic
  document = KanjidicDocument.new
  parser = Nokogiri::XML::SAX::Parser.new(document)
  puts 'parsing XML...'
  File.open('db/seed_data/kanjidic2.xml') do |f|
    parser.parse(f)
  end

  # valid_records = document.records.reject do |r|
  #   r.readings.empty? || r.meanings.empty?
  # end

  valid_records = document.records

  fields = valid_records.map do |r|
    {
      glyph: r.literal,
      meanings: r.meanings.join(', '),
      readings: r.readings.join(', '),
      grade: r.grade,
      strokes: r.stroke_count
    }
  end

  failed = []
  puts 'loading in DB (this may take a while)...'
  Kanji.transaction do
    Kanji.create(fields).each do |k|
      next if k.errors.empty?

      failed << k
    end
  end

  if failed.empty?
    puts 'success'
  else
    puts "completed with #{failed.count} failures."
  end
end
# rubocop: enable Metrics/AbcSize, Metrics/MethodLength

load_kanjidic

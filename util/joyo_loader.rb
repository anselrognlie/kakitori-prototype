# frozen_string_literal: true

require_relative 'joyo_document'

def parse_joyo
  document = JoyoDocument.new
  puts 'reading CSV...'
  document.read('db/seed_data/joyo.csv')

  valid_records = document.records

  fields = valid_records.map do |r|
    {
      glyph: r.glyph,
      gloss: r.gloss,
      joyo_level_id: r.joyo,
      jlpt_level_id: r.jlpt
    }
  end

  failed = []
  puts 'updating DB (this might take a while)...'
  Kanji.transaction do
    fields.each do |r|
      kanjis = Kanji.where(glyph: r[:glyph])
      raise unless kanjis.count == 1

      k = kanjis.first
      k.update(r)
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

parse_joyo

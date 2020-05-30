# frozen_string_literal: true

require_relative 'kanjidic_document'
require_relative 'step_writer'
require_relative 'status_writer'

module KTL
  module_function

  STATUS_MSG = 'Saving records... (%<num>d of %<total>d, %<percent>d%%)'

  # rubocop: disable Metrics/AbcSize, Metrics/MethodLength
  def main
    document = KanjidicDocument.new
    parser = Nokogiri::XML::SAX::Parser.new(document)
    StepWriter.log('Parsing XML...', long: true) do
      File.open('db/seed_data/kanjidic2.xml') do |f|
        parser.parse(f)
        true
      rescue KanjidicError
        false
      end
    end

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
    writer = StatusWriter.new
    writer.start(count: fields.size, template: STATUS_MSG, every: 100)
    Kanji.transaction do
      fields.each do |rec|
        writer.next_step
        k = Kanji.create(rec)
        next if k.errors.empty?

        failed << k
      end
    end
    writer.done

    return if failed.empty?

    puts "Completed with #{failed.count} failures."
  end
  # rubocop: enable Metrics/AbcSize, Metrics/MethodLength
end

KTL.main

# frozen_string_literal: true

require_relative 'joyo_document'
require_relative 'step_writer'
require_relative 'status_writer'

module KTL
  module_function

  STATUS_MSG = 'Saving records... (%<num>d of %<total>d, %<percent>d%%)'

  # rubocop: disable Metrics/MethodLength, Metrics/AbcSize
  def main
    document = JoyoDocument.new
    StepWriter.log('Reading CSV...') do
      document.read('db/seed_data/joyo.csv')
    end

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
    writer = StatusWriter.new
    writer.start(count: fields.size, template: STATUS_MSG, every: 100)
    Kanji.transaction do
      fields.each do |r|
        writer.next_step
        kanjis = Kanji.where(glyph: r[:glyph])
        if kanjis.count == 1
          k = kanjis.first
          k.update(r)
          next if k.errors.empty?
        end

        failed << k
      end
    end
    writer.done

    return if failed.empty?

    puts "Completed with #{failed.count} failures."
  end
  # rubocop: enable Metrics/MethodLength, Metrics/AbcSize
end

KTL.main

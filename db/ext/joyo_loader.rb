# frozen_string_literal: true

require_relative 'joyo_document'
require_relative 'step_writer'
require_relative 'status_writer'
require_relative 'path_utils'
require_relative 'data_source_config'

module KTL
  module_function

  STATUS_MSG = 'Saving records... (%<num>d of %<total>d, %<percent>d%%)'
  TEMP_DIR = 'tmp_import'
  TEMP_ARCHIVE = 'joyo.csv'
  SCALAR_FIELDS = %i[joyo_level jlpt_level].freeze

  def commit_record(kanji, record)
    joyo = JoyoImport.new(record.slice(*SCALAR_FIELDS).merge(kanji: kanji))
    saved = joyo.save
    commit_glosses(kanji, record[:gloss]) if saved

    [record[:glyph], saved]
  rescue ActiveRecord::ActiveRecordError
    [record[:glyph], false]
  end

  def normalize_gloss(gloss)
    gloss.downcase.gsub(/[^a-z0-9]/, '')
  end

  def commit_glosses(kanji, glosses)
    glosses.each do |gloss|
      normalized = normalize_gloss(gloss)
      JoyoGloss.create(
        {
          kanji: kanji, gloss: gloss,
          normalized: normalized
        }
      )
    end
  end

  def commit_record_with_transaction(record, failed)
    glyph = record[:glyph]
    kanjis = KanjidicMain.where(glyph: glyph)
    return failed << glyph unless kanjis.count == 1

    kanji = kanjis.first
    JoyoImport.transaction do
      glyph, saved = commit_record(kanji, record)
      saved ? failed : failed << glyph
    end
  end

  def commit(records, message: nil, every: 1)
    writer = StatusWriter.new
    writer.start(count: records.size, template: message, every: every) do
      records.reduce([]) do |failed, rec|
        writer.next_step
        commit_record_with_transaction(rec, failed)
      end
    end
  end

  # rubocop: disable Metrics/MethodLength, Metrics/AbcSize
  def main
    PathUtils.clean_path(TEMP_DIR, recreate: true)

    data_source = DataSourceConfig.new
    joyo_url = nil
    StepWriter.log('Loading import locations...') do
      config = data_source.config
      joyo_url = config&.dig(:kakitori, :sources, :joyo, :url)
    end

    return unless joyo_url

    response = nil
    StepWriter.log('Downloading joyo data...', long: true) do
      response = HTTParty.get(joyo_url)
    end

    return unless response

    out_archive = File.join(TEMP_DIR, TEMP_ARCHIVE)
    StepWriter.log('Writing to disk...', long: true) do
      File.open(out_archive, 'wb') do |file|
        file.write response.body
      end
    end

    document = JoyoDocument.new
    StepWriter.log('Reading CSV...') do
      document.read(out_archive)
    end

    fields = document.records.map do |r|
      {
        glyph: r.glyph,
        gloss: r.gloss,
        joyo_level: r.joyo,
        jlpt_level: r.jlpt
      }
    end

    failed = commit(fields, message: STATUS_MSG, every: 100)

    return if failed.empty?

    puts "Completed with #{failed.count} failures."
  ensure
    PathUtils.clean_path(TEMP_DIR)
  end
  # rubocop: enable Metrics/MethodLength, Metrics/AbcSize
end

KTL.main

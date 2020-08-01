# frozen_string_literal: true

require_relative 'kanken_document'
require_relative 'step_writer'
require_relative 'status_writer'
require_relative 'path_utils'
require_relative 'data_source_config'

module KTL
  module_function

  STATUS_MSG = 'Saving records... (%<num>d of %<total>d, %<percent>d%%)'
  TEMP_DIR = 'tmp_import'
  TEMP_ARCHIVE = 'kanken.csv'
  SCALAR_FIELDS = %i[glyph level].freeze
  OFFLINE = true

  def commit_record(record)
    kanji = record[:glyph]
    kanken = KankenImport.new(record.slice(*SCALAR_FIELDS))
    saved = kanken.save
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
      KankenImportGloss.create(
        {
          glyph: kanji, gloss: gloss,
          normalized: normalized
        }
      )
    end
  end

  def commit_record_with_transaction(record, failed)
    KankenImport.transaction do
      glyph, saved = commit_record(record)
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

  # rubocop: disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
  def main
    PathUtils.clean_path(TEMP_DIR, recreate: true) unless OFFLINE
    out_archive = File.join(TEMP_DIR, TEMP_ARCHIVE)

    unless OFFLINE
      data_source = DataSourceConfig.new
      kanken_url = nil
      StepWriter.log('Loading import locations...') do
        config = data_source.config
        kanken_url = config&.dig(:kakitori, :sources, :kanken, :url)
      end

      return unless kanken_url

      response = nil
      StepWriter.log('Downloading kanken data...', long: true) do
        response = HTTParty.get(kanken_url)
      end

      return unless response

      StepWriter.log('Writing to disk...', long: true) do
        File.open(out_archive, 'wb') do |file|
          file.write response.body
        end
      end
    end

    document = KankenDocument.new
    StepWriter.log('Reading CSV...') do
      document.read(out_archive)
    end

    fields = document.records.map do |r|
      {
        glyph: r.glyph,
        gloss: r.gloss,
        level: r.level
      }
    end

    failed = commit(fields, message: STATUS_MSG, every: 100)

    return if failed.empty?

    puts "Completed with #{failed.count} failures."
  ensure
    PathUtils.clean_path(TEMP_DIR) unless OFFLINE
  end
  # rubocop: enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
end

KTL.main

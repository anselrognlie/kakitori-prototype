# frozen_string_literal: true

require_relative 'jlpt_document'
require_relative 'step_writer'
require_relative 'status_writer'
require_relative 'path_utils'
require_relative 'data_source_config'

module KTL
  module_function

  STATUS_MSG = 'Saving records... (%<num>d of %<total>d, %<percent>d%%)'
  TEMP_DIR = 'tmp_import'
  TEMP_ARCHIVE = 'jlpt.csv'
  SCALAR_FIELDS = %i[glyph level].freeze
  OFFLINE = true

  def commit_record(record)
    jlpt = JlptImport.new(record.slice(*SCALAR_FIELDS))
    saved = jlpt.save

    [record[:glyph], saved]
  rescue ActiveRecord::ActiveRecordError
    [record[:glyph], false]
  end

  def commit_record_with_transaction(record, failed)
    JlptImport.transaction do
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
      # data_source = DataSourceConfig.new
      # jlpt_url = nil
      # StepWriter.log('Loading import locations...') do
      #   config = data_source.config
      #   jlpt_url = config&.dig(:kakitori, :sources, :jlpt, :url)
      # end

      # return unless jlpt_url

      # response = nil
      # StepWriter.log('Downloading jlpt data...', long: true) do
      #   response = HTTParty.get(jlpt_url)
      # end

      # return unless response

      # StepWriter.log('Writing to disk...', long: true) do
      #   File.open(out_archive, 'wb') do |file|
      #     file.write response.body
      #   end
      # end
    end

    document = JlptDocument.new
    StepWriter.log('Reading CSV...') do
      document.read(out_archive)
    end

    fields = document.records.map do |r|
      {
        glyph: r.glyph,
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

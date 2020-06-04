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

  def commit_record(kanji, updates, failed)
    kanji.update(updates)
    kanji.errors.empty? ? failed : failed << kanji
  rescue ActiveRecord::ActiveRecordError
    failed << kanji
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
          commit_record(k, r, failed)
          next if k.errors.empty?
        end

        failed << k
      end
    end
    writer.done

    return if failed.empty?

    puts "Completed with #{failed.count} failures."
  ensure
    PathUtils.clean_path(TEMP_DIR)
  end
  # rubocop: enable Metrics/MethodLength, Metrics/AbcSize
end

KTL.main

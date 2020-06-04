# frozen_string_literal: true

require_relative 'kanjidic_document'
require_relative 'status_writer'
require_relative 'step_writer'
require_relative 'path_utils'
require_relative 'data_source_config'
require 'zlib'

module KTL
  module_function

  STATUS_MSG = 'Saving records... (%<num>d of %<total>d, %<percent>d%%)'
  TEMP_DIR = 'tmp_import'
  TEMP_ARCHIVE = 'kanjidic.xml.gz'

  def extract(path, status: nil)
    document = KanjidicDocument.new
    parser = Nokogiri::XML::SAX::Parser.new(document)
    StepWriter.log(status, long: true) do
      extract_with_parser(path, parser)
    end

    document.records
  end

  def extract_with_parser(path, parser)
    Zlib::GzipReader.open(path) do |f|
      parser.parse(f)
      true
    rescue KanjidicError
      false
    end
  end

  def pack_records(records)
    records.map do |r|
      {
        glyph: r.literal,
        meanings: r.meanings.join(', '),
        readings: r.readings.join(', '),
        grade: r.grade,
        strokes: r.stroke_count
      }
    end
  end

  def commit_record(record, failed)
    k = Kanji.create(record)
    k.errors.empty? ? failed : failed << k
  rescue ActiveRecord::ActiveRecordError
    failed << k
  end

  def commit(records, message: nil, every: 1)
    writer = StatusWriter.new
    writer.start(count: records.size, template: message, every: every) do
      Kanji.transaction do
        records.reduce([]) do |failed, rec|
          writer.next_step
          commit_record(rec, failed)
        end
      end
    end
  end

  # rubocop: disable Metrics/MethodLength, Metrics/AbcSize
  def main
    PathUtils.clean_path(TEMP_DIR, recreate: true)

    data_source = DataSourceConfig.new
    kanjidic_url = nil
    StepWriter.log('Loading import locations...') do
      config = data_source.config
      kanjidic_url = config&.dig(:kakitori, :sources, :kanjidic, :url)
    end

    return unless kanjidic_url

    response = nil
    StepWriter.log('Downloading kanjidic archive...', long: true) do
      response = HTTParty.get(kanjidic_url)
    end

    return unless response

    out_archive = File.join(TEMP_DIR, TEMP_ARCHIVE)
    StepWriter.log('Writing to disk...', long: true) do
      File.open(out_archive, 'wb') do |file|
        file.write response.body
      end
    end

    records = extract(out_archive, status: 'Parsing XML...')
    packed = pack_records(records)
    failed = commit(packed, message: STATUS_MSG, every: 100)

    return if failed.empty?

    puts "Completed with #{failed.count} failures."
  ensure
    PathUtils.clean_path(TEMP_DIR)
  end
  # rubocop: enable Metrics/MethodLength, Metrics/AbcSize
end

KTL.main

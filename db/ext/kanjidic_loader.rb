# frozen_string_literal: true

require_relative 'kanjidic_document'
require_relative 'status_writer'
require_relative 'step_writer'
require_relative 'path_utils'
require_relative 'data_source_config'
require 'zlib'

# rubocop: disable Metrics/ModuleLength
module KTL
  module_function

  STATUS_MSG = 'Saving records... (%<num>d of %<total>d, %<percent>d%%)'
  TEMP_DIR = 'tmp_import'
  TEMP_ARCHIVE = 'kanjidic.xml.gz'
  SCALAR_FIELDS = %i[glyph grade strokes codepoint jlpt_old frequency].freeze
  OFFLINE = true

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

  # rubocop: disable Metrics/MethodLength
  def pack_records(records)
    records.map do |r|
      {
        glyph: r.literal,
        meanings: r.meanings,
        readings: r.readings,
        grade: r.grade,
        strokes: r.stroke_count,
        codepoint: r.codepoint,
        jlpt_old: r.jlpt,
        frequency: r.frequency
      }
    end
  end
  # rubocop: enable Metrics/MethodLength

  def normalize_meaning(meaning)
    meaning.downcase.gsub(/[^a-z0-9]/, '')
  end

  def commit_meanings(record, meanings)
    meanings.each do |meaning|
      normalized = normalize_meaning(meaning)
      KanjidicImportMeaning.create(
        {
          kanji: record,
          meaning: meaning,
          normalized: normalized
        }
      )
    end
  end

  def normalize_reading(reading)
    Moji.kata_to_hira(reading).gsub(/./) { |c| Moji.type?(c, Moji::HIRA) ? c : '' }
  end

  def commit_readings(record, readings)
    readings.each do |reading|
      normalized = normalize_reading(reading[:reading])
      type = ReadingType.restrict(reading[:type])
      KanjidicImportReading.create(
        {
          kanji: record, reading: reading[:reading],
          normalized: normalized, type: type
        }
      )
    end
  end

  def commit_record(record)
    k = KanjidicImport.new(record.slice(*SCALAR_FIELDS))
    saved = k.save
    if saved
      commit_meanings(k, record[:meanings])
      commit_readings(k, record[:readings])
    end

    [k, saved]
  rescue ActiveRecord::ActiveRecordError
    [k, false]
  end

  def commit_transacted_record(record, failed)
    KanjidicImport.transaction do
      k, saved = commit_record(record)
      saved ? failed : failed << k
    end
  end

  def commit(records, message: nil, every: 1)
    writer = StatusWriter.new
    writer.start(count: records.size, template: message, every: every) do
      records.reduce([]) do |failed, rec|
        writer.next_step
        commit_transacted_record(rec, failed)
      end
    end
  end

  # rubocop: disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
  def main
    PathUtils.clean_path(TEMP_DIR, recreate: true) unless OFFLINE
    out_archive = File.join(TEMP_DIR, TEMP_ARCHIVE)

    unless OFFLINE
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

      StepWriter.log('Writing to disk...', long: true) do
        File.open(out_archive, 'wb') do |file|
          file.write response.body
        end
      end
    end

    records = extract(out_archive, status: 'Parsing XML...')
    packed = pack_records(records)
    failed = commit(packed, message: STATUS_MSG, every: 100)

    return if failed.empty?

    puts "Completed with #{failed.count} failures."
    warn failed.map(&:glyph).join(',')
  ensure
    PathUtils.clean_path(TEMP_DIR) unless OFFLINE
  end
  # rubocop: enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
end
# rubocop: enable Metrics/ModuleLength

KTL.main

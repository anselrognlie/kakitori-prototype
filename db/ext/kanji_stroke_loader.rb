# frozen_string_literal: true

require_relative 'step_writer'
require_relative 'path_utils'
require_relative 'zip_archive'
require_relative 'step_writer'
require_relative 'data_source_config'

module KTL
  TEMP_DIR = 'tmp_import'
  TEMP_ARCHIVE = 'main.zip'

  module_function

  # rubocop: disable Metrics/MethodLength, Metrics/AbcSize
  def main
    PathUtils.clean_path(TEMP_DIR, recreate: true)

    data_source = DataSourceConfig.new
    kanjivg_url = nil
    StepWriter.log('Loading import locations...') do
      config = data_source.config
      kanjivg_url = config&.dig(:kakitori, :sources, :kanjivg, :url)
    end

    return unless kanjivg_url

    response = nil
    StepWriter.log('Downloading kanjivg archive...', long: true) do
      response = HTTParty.get(kanjivg_url)
    end

    return unless response

    out_archive = File.join(TEMP_DIR, TEMP_ARCHIVE)
    StepWriter.log('Writing to disk...', long: true) do
      File.open(out_archive, 'wb') do |file|
        file.write response.body
      end
    end

    archive = ZipArchive.new(out_archive, to: TEMP_DIR, every: 100)
    archive.extract
  ensure
    PathUtils.clean_path(TEMP_DIR)
  end
  # rubocop: enable Metrics/MethodLength, Metrics/AbcSize
end

KTL.main

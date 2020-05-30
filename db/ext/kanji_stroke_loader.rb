# frozen_string_literal: true

require_relative 'step_writer'
require_relative 'path_utils'
require_relative 'kanji_archive'
require_relative 'github_import'

module KTL
  TEMP_DIR = 'tmp_kvg'
  TEMP_ARCHIVE = 'main.zip'

  module_function

  # rubocop: disable Metrics/MethodLength
  def main
    PathUtils.clean_path(TEMP_DIR, recreate: true)

    api = GithubApi.new
    response = nil
    StepWriter.log('Downloading kanjivg archive...', true) do
      response = api.latest_main_release
    end

    return unless response

    out_archive = File.join(TEMP_DIR, TEMP_ARCHIVE)
    File.open(out_archive, 'wb') do |file|
      file.write response.body
    end

    archive = KanjiArchive.new(out_archive, to: TEMP_DIR)
    archive.extract
  ensure
    PathUtils.clean_path(TEMP_DIR)
  end
  # rubocop: enable Metrics/MethodLength
end

KTL.main

# StepWriter.log('Counting up...', true) do
#   100_000_000.times {}
# end

# writer = StatusWriter.new
# writer.start(
#   count: 100_000,
#   template: 'Processing %<step>d (%<num>d of %<total>d, %<percent>d%%)'
# )
# 100_000.times { |i| writer.next_step(i + 1) }
# writer.done

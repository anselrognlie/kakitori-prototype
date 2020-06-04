# frozen_string_literal: true

require 'zip'

require_relative 'status_writer'
require_relative 'step_writer'
require_relative 'path_utils'

module KTL
  class ZipArchive
    STATUS_MSG = 'Extracting %<step>s (%<num>d of %<total>d, %<percent>d%%)'

    def initialize(filename, writer = nil, to: nil, every: 1)
      @filename = filename
      @to = to
      @writer = writer || StatusWriter.new
      @every = every
    end

    def entry_name(entry)
      @to ? File.join(@to, entry.name) : entry.name
    end

    def safe_extract(entry)
      name = entry_name(entry)
      PathUtils.ensure_path(name)
      entry.extract(name)
    end

    def extract
      StepWriter.log('Reading archive...', long: true)
      Zip::File.open(@filename) do |zip_file|
        StepWriter.done
        @writer.start(count: zip_file.size, template: STATUS_MSG, every: @every) do
          # Handle entries one by one
          zip_file.each do |entry|
            @writer.next_step entry.name

            # Extract to file or directory based on name in the archive
            safe_extract(entry)
          end
        end
      end
    end
  end
end

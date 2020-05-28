# frozen_string_literal: true

require 'zip'
require 'fileutils'

module KVG
  class GithubApi
    include HTTParty

    base_uri 'https://api.github.com'
    ACCEPT = 'application/vnd.github.v3+json'
    OWNER = 'KanjiVG'
    REPO = 'kanjivg'

    def releases
      # byebug
      get_sym "/repos/#{OWNER}/#{REPO}/releases", accept_header
    end

    def latest_release
      get_sym "/repos/#{OWNER}/#{REPO}/releases/latest", accept_header
    end

    def main_download_url
      latest_release[:assets]
        .find { |asset| asset[:name].include? 'main' }
        &.dig(:browser_download_url)
    rescue SocketError
      nil
    end

    def latest_main_release
      url = main_download_url
      return unless url

      HTTParty.get(url)
    rescue SocketError
      nil
    end

    def accept_header
      { headers: { accept: ACCEPT } }
    end

    def get_sym(path, options)
      r = self.class.get path, options.merge(format: :plain)
      JSON.parse r, symbolize_names: true
    end
  end

  class LinePrinter
    def print(str)
      line = "\r#{str}"
      spaces = last_len - line.length
      line = "#{line}#{' ' * spaces}" if spaces.positive?
      @last_str = str.to_s
      global_print line
    end

    def clear
      line = "\r#{' ' * last_len}"
      @last_str = nil
      global_print line
    end

    def done
      puts
    end

    private

    def last_len
      @last_str&.length || 0
    end

    def global_print(str)
      Object.instance_method(:print).bind(self).call(str)
    end
  end

  class StepWriter
    class << self
      def log(msg, long_running = false, &block)
        init(msg, long_running, block)
        print @msg
        wait_for_task
        process_block
      end

      def done
        join
        puts ' done.' if @pending
        @pending = false
      end

      def error
        join
        puts ' error!' if @pending
        @pending = false
      end

      private

      TWIRL = %w[- \\ | /].freeze

      def init(msg, long_running, block)
        @msg = msg
        @pending = true
        @long_running = long_running
        @done = false
        @twirl = 0
        @block = block
      end

      def wait_for_task
        return unless @long_running

        print " #{twirl}"
        @thread = Thread.fork do
          twiddle
          until @done
            print "\r#{@msg} #{twirl}"
            sleep 1.0 / 8.0
          end
          print "\r#{@msg}"
        end
      end

      def twiddle
        sleep 1.0 / 4.0
      end

      def twirl
        str = TWIRL[@twirl]
        @twirl = (@twirl + 1) % TWIRL.count
        str
      end

      def join
        @done = true
        @thread&.join
      end

      def process_block
        return unless @block

        if @block.call
          done
        else
          error
        end
      end
    end
  end

  class StatusWriter
    def initialize(printer = nil)
      @printer = printer || LinePrinter.new
      start
    end

    def start(count: 0, template: '')
      @step = 0
      @step_count = count
      @template = template
    end

    def next_step(msg)
      @step += 1
      line = format(
        @template, step: msg, num: @step, total: @step_count,
                   percent: step_percent
      )
      @printer.print(line)
    end

    def done
      @printer.done
      start
    end

    private

    def step_percent
      @step_count.zero? ? 0 : (@step * 100.0 / @step_count).round
    end
  end

  class PathUtils
    class << self
      def ensure_path(path)
        dir = File.dirname(path)
        FileUtils.mkdir_p dir if dir
      end

      def clean_path(path, recreate: false)
        FileUtils.remove_entry_secure(path) if File.exist? path
        FileUtils.mkdir_p path if recreate
      end
    end
  end

  class KanjiArchive
    STATUS_MSG = 'Extracting %<step>s (%<num>d of %<total>d, %<percent>d%%)'

    def initialize(filename, writer = nil, to: nil)
      @filename = filename
      @to = to
      @writer = writer || StatusWriter.new
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
      StepWriter.log('Reading archive...', true)
      Zip::File.open(@filename) do |zip_file|
        StepWriter.done
        @writer.start(count: zip_file.size, template: STATUS_MSG)

        # Handle entries one by one
        zip_file.each do |entry|
          @writer.next_step entry.name

          # Extract to file or directory based on name in the archive
          safe_extract(entry)
        end
        @writer.done
      end
    end
  end
end

TEMP_DIR = 'tmp_kvg'
TEMP_ARCHIVE = 'main.zip'

begin
  KVG::PathUtils.clean_path(TEMP_DIR, recreate: true)

  api = KVG::GithubApi.new
  response = nil
  KVG::StepWriter.log('Downloading kanjivg archive...', true) do
    response = api.latest_main_release
  end

  return unless response

  out_archive = File.join(TEMP_DIR, TEMP_ARCHIVE)
  File.open(out_archive, 'wb') do |file|
    file.write response.body
  end

  archive = KVG::KanjiArchive.new(out_archive, to: TEMP_DIR)
  archive.extract
ensure
  KVG::PathUtils.clean_path(TEMP_DIR)
end

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

# frozen_string_literal: true

require 'zip'
require 'fileutils'

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
  end

  def latest_main_release
    url = main_download_url
    return unless url

    HTTParty.get(url)
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
    line = "\r#{' ' * (last_len)}"
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

class KanjiArchive
  def initialize(filename)
    @filename = filename
  end

  def ensure_path(path)
    dir = File.dirname(path)
    FileUtils.mkdir_p dir if dir
  end

  def extract
    print "Reading archive... "
    Zip::File.open(@filename) do |zip_file|
      puts "done."
      lp = LinePrinter.new
      file_count = zip_file.size
      f = 0
      # Handle entries one by one
      zip_file.each do |entry|
        # puts "Extracting #{entry.name}"
        percent = (f * 100.0 / file_count).round
        f += 1
        # lp.clear
        lp.print "Extracting #{entry.name} " \
          "(#{f} of #{file_count}, #{percent}%)"
        path = entry.name

        # # Extract to file or directory based on name in the archive
        ensure_path(path)
        entry.extract

        # # Read into memory
        # content = entry.get_input_stream.read
      end
      lp.done

      # # Find specific entry
      # entry = zip_file.glob('*.csv').first
      # raise 'File too large when extracted' if entry.size > MAX_SIZE
      # puts entry.get_input_stream.read
    end
  end
end

TEMP_ARCHIVE = 'out.zip'

# should clear the old tempfile and any extracted data
# that exists

api = GithubApi.new
response = api.latest_main_release
File.open(TEMP_ARCHIVE, 'wb') do |file|
  file.write response.body
end

archive = KanjiArchive.new(TEMP_ARCHIVE)
archive.extract

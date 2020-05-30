# frozen_string_literal: true

require 'fileutils'

module KTL
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
end

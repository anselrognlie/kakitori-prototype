# frozen_string_literal: true

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
end

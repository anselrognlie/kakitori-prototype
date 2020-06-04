# frozen_string_literal: true

module KTL
  class DataSourceConfig
    include HTTParty

    DATASRC_CONFIG_URL = ENV['DATASRC_CONFIG_URL']

    def config
      @config ||= get_sym(DATASRC_CONFIG_URL)
    rescue SocketError
      nil
    end

    def get_sym(path, options = {})
      r = self.class.get path, options.merge(format: :plain)
      JSON.parse r, symbolize_names: true
    end
  end
end

# frozen_string_literal: true

require_relative '../utilities/ostruct_ext.rb'

class WkApi
  API_KEY = ENV['WK_API_KEY']
  BASE_URL = 'https://api.wanikani.com/v2/'

  def initialize(api_key = nil)
    @api_key = api_key || API_KEY
  end

  def query_user_data
    response = HTTParty.get("#{BASE_URL}user", { headers: make_header, format: :json })
    OpenStruct.unpack_hash(response['data'])
  end

  # rubocop: disable Metrics/MethodLength
  def query_subjects(max_level)
    done = false
    results = []
    next_url = "#{BASE_URL}subjects"
    query_args = {
      levels: make_level_query(max_level),
      types: 'kanji'
    }

    until done
      response = HTTParty.get(next_url, {
                                query: query_args,
                                headers: make_header,
                                format: :json
                              })

      results += response['data'].map do |k|
        OpenStruct.new(k['data'])
      end

      next_url = response['pages']['next_url']
      query_args = {}
      done = true if next_url.nil?
    end

    results
  end
  # rubocop: enable Metrics/MethodLength

  def make_level_query(max_level)
    (1..max_level).to_a.join(',')
  end

  def token
    @api_key
  end

  private

  def make_header
    {
      'Wanikani-Revision' => '20170710',
      Authorization: 'Bearer ' + @api_key,
      'Content-Type' => 'application/json',
      'Accept-Content-Type' => 'application/json'
    }
  end
end

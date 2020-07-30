# frozen_string_literal: true

require 'httparty'
require 'ostruct'

module KTL
  API_KEY = ENV['WK_API_KEY']
  BASE_URL = 'https://api.wanikani.com/v2/'

  module_function

  def make_header
    {
      'Wanikani-Revision' => '20170710',
      Authorization: 'Bearer ' + API_KEY,
      'Content-Type' => 'application/json',
      'Accept-Content-Type' => 'application/json'
    }
  end

  # max_level_granted: r['max_level_granted'],
  # period_ends_at: r['period_ends_at']

  def query_user_data
    response = HTTParty.get("#{BASE_URL}user", { headers: make_header, format: :json })
    subscription = response['data']['subscription']
    OpenStruct.new(subscription)
  end

  # rubocop: disable Metrics/MethodLength, Metrics/AbcSize
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
      # byebug

      results += response['data'].map do |k|
        OpenStruct.new(k['data'])
      end

      next_url = response['pages']['next_url']
      query_args = {}
      done = true if next_url.nil?
    end

    results
  end
  # rubocop: enable Metrics/MethodLength, Metrics/AbcSize

  def make_level_query(max_level)
    (1..max_level).to_a.join(',')
  end

  def main
    # puts ENV['DATASRC_CONFIG_URL']
    # puts ENV['WK_API_KEY']
    level = query_user_data.max_level_granted
    # level = 60
    # puts "retrieving data up to level #{level}..."
    # levels = make_level_query(level)
    # puts levels
    level_data = query_subjects(level)
    # level_data.each do |k|
    #   puts "#{k.characters},#{k.level}"
    # end
    puts level_data.to_json
  end
end

KTL.main

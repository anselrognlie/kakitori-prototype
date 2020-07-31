# frozen_string_literal: true

require 'nokogiri'
require 'byebug'

module KTL
  class KanjidicError < StandardError; end

  class KanjiRecord
    attr_reader :literal, :grade, :stroke_count, :readings, :meanings, :codepoint, :jlpt, :frequency

    def initialize(**args)
      @literal = args[:literal]
      @grade = args[:grade]
      @stroke_count = args[:stroke_count]
      @readings = args[:readings].dup.freeze
      @meanings = args[:meanings].dup.freeze
      @codepoint = args[:codepoint]
      @jlpt = args[:jlpt]
      @frequency = args[:frequency]
    end
  end

  # rubocop: disable Metrics/ClassLength
  class KanjidicDocument < Nokogiri::XML::SAX::Document
    attr_reader :records

    READING_TYPE = 'r_type'
    JAPANESE_READING = 'ja_'
    NANORI_TYPE = 'nanori'
    MEANING_LANGUAGE = 'm_lang'
    CODEPOINT_TYPE = 'cp_type'
    UCS_CODEPOINT = 'ucs'

    def initialize
      set_handlers
      reset
    end

    def reset
      @path = []
      @records = []
    end

    def push_path(to:, from: nil)
      if from.nil?
        raise KanjidicError unless @path.empty?
      else
        raise KanjidicError unless @path.last == from
      end

      @path << to
    end

    def pop_path(from:)
      raise KanjidicError unless @path.last == from

      @path.pop
    end

    def in_path?(path)
      @path.last == path
    end

    # rubocop: disable Metrics/AbcSize, Metrics/MethodLength
    def make_start_handlers
      @start_handlers = {
        character: ->(name, _attrs) { start_character(name) },
        literal: ->(name, _attrs) { push_path(to: name, from: :character) },
        grade: ->(name, _attrs) { push_path(to: name, from: :character) },
        stroke_count: ->(name, _attrs) { push_path(to: name, from: :character) },
        reading: ->(name, attrs) { start_reading(name, attrs) },
        meaning: ->(name, attrs) { start_meaning(name, attrs) },
        nanori: ->(name, _attrs) { push_path(to: name, from: :character) },
        cp_value: ->(name, attrs) { start_ucs(name, attrs) },
        jlpt: ->(name, _attrs) { push_path(to: name, from: :character) },
        freq: ->(name, _attrs) { push_path(to: name, from: :character) }
      }.freeze
    end
    # rubocop: enable Metrics/AbcSize, Metrics/MethodLength

    # rubocop: disable Metrics/AbcSize, Metrics/MethodLength
    def make_end_handlers
      @end_handlers = {
        character: ->(name) { end_character(name) },
        literal: ->(name) { pop_path(from: name) },
        grade: ->(name) { pop_path(from: name) },
        stroke_count: ->(name) { pop_path(from: name) },
        reading: ->(name) { pop_path(from: name) },
        meaning: ->(name) { pop_path(from: name) },
        nanori: ->(name) { pop_path(from: name) },
        cp_value: ->(name) { pop_path(from: name) },
        jlpt: ->(name) { pop_path(from: name) },
        freq: ->(name) { pop_path(from: name) }
      }.freeze
    end
    # rubocop: enable Metrics/AbcSize, Metrics/MethodLength

    # rubocop: disable Metrics/MethodLength, Metrics/AbcSize
    def make_character_handlers
      @character_handlers = [
        { condition: -> { in_path?(:literal) },
          handler: ->(str) { @literal = str } },
        { condition: -> { in_path?(:grade) },
          handler: ->(str) { @grade = str.to_i } },
        { condition: -> { in_path?(:stroke_count) },
          handler: ->(str) { @stroke_count = str.to_i } },
        { condition: -> { in_path?(:reading) },
          handler: ->(str) { handle_reading(str) } },
        { condition: -> { in_path?(:meaning) },
          handler: ->(str) { @meanings << str if @valid_meaning } },
        { condition: -> { in_path?(:nanori) },
          handler: ->(str) { @readings << { type: NANORI_TYPE, reading: str } } },
        { condition: -> { in_path?(:cp_value) },
          handler: ->(str) { @codepoint = str if @ucs } },
        { condition: -> { in_path?(:jlpt) },
          handler: ->(str) { @jlpt = str.to_i } },
        { condition: -> { in_path?(:freq) },
          handler: ->(str) { @frequency = str.to_i } }
      ].freeze
    end
    # rubocop: enable Metrics/MethodLength, Metrics/AbcSize

    def set_handlers
      make_start_handlers
      make_end_handlers
      make_character_handlers
    end

    def start_element(name, attrs = [])
      # byebug if name == 'character'
      sym = name.to_sym
      handler = @start_handlers[sym]
      handler&.call(sym, attrs)
    end

    def end_element(name)
      sym = name.to_sym
      handler = @end_handlers[sym]
      handler&.call(sym)
    end

    def start_character(name)
      push_path(to: name)
      reset_kanji
    end

    def start_reading(name, attrs)
      push_path(to: name, from: :character)
      @valid_reading, @reading_type = validate_reading_attrs(attrs)
    end

    def validate_reading_attrs(attrs)
      all_type = attrs.assoc(READING_TYPE)&.at(1)
      valid = all_type&.start_with?(JAPANESE_READING)
      type = valid ? all_type[3..] : nil
      [valid, type]
    end

    def handle_reading(str)
      @readings << { type: @reading_type, reading: str } if @valid_reading
    end

    def start_meaning(name, attrs)
      push_path(to: name, from: :character)
      @valid_meaning = attrs.assoc(MEANING_LANGUAGE).nil?
    end

    def start_ucs(name, attrs)
      push_path(to: name, from: :character)
      @ucs = (attrs.assoc(CODEPOINT_TYPE)&.at(1) == UCS_CODEPOINT)
    end

    # rubocop: disable Metrics/MethodLength
    def end_character(sym)
      pop_path(from: sym)

      record = KanjiRecord.new(
        literal: @literal,
        grade: @grade,
        stroke_count: @stroke_count,
        readings: @readings,
        meanings: @meanings,
        codepoint: @codepoint,
        jlpt: @jlpt,
        frequency: @frequency
      )

      # print "#{@records.count + 1}: #{record.literal},"
      return if @readings.empty? && @meanings.empty?

      @records << record
    end
    # rubocop: enable Metrics/MethodLength

    def reset_kanji
      @literal = ''
      @grade = 0
      @stroke_count = 0
      @readings = []
      @meanings = []
      @codepoint = ''
      @jlpt = 0
      @frequency = 0
    end

    def characters(str)
      @character_handlers.each do |entry|
        if entry[:condition].call
          entry[:handler].call(str)
          break
        end
      end
    end
  end
  # rubocop: enable Metrics/ClassLength
end

# frozen_string_literal: true

require 'nokogiri'
require 'byebug'

module KTL
  class KanjidicError < StandardError; end

  class KanjiRecord
    attr_reader :literal, :grade, :stroke_count
    attr_reader :readings, :meanings

    def initialize(literal:, grade:, stroke_count:, readings:, meanings:)
      @literal = literal
      @grade = grade
      @stroke_count = stroke_count
      @readings = readings.dup.freeze
      @meanings = meanings.dup.freeze
    end
  end

  # rubocop: disable Metrics/ClassLength
  class KanjidicDocument < Nokogiri::XML::SAX::Document
    attr_reader :records

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

    # rubocop: disable Metrics/AbcSize
    def make_start_handlers
      @start_handlers = {
        character: ->(name, _attrs) { start_character(name) },
        literal: ->(name, _attrs) { push_path(to: name, from: :character) },
        grade: ->(name, _attrs) { push_path(to: name, from: :character) },
        stroke_count: ->(name, _attrs) { push_path(to: name, from: :character) },
        reading: ->(name, attrs) { start_reading(name, attrs) },
        meaning: ->(name, attrs) { start_meaning(name, attrs) },
        nanori: ->(name, _attrs) { push_path(to: name, from: :character) }
      }.freeze
    end
    # rubocop: enable Metrics/AbcSize

    # rubocop: disable Metrics/AbcSize
    def make_end_handlers
      @end_handlers = {
        character: ->(name) { end_character(name) },
        literal: ->(name) { pop_path(from: name) },
        grade: ->(name) { pop_path(from: name) },
        stroke_count: ->(name) { pop_path(from: name) },
        reading: ->(name) { pop_path(from: name) },
        meaning: ->(name) { pop_path(from: name) },
        nanori: ->(name) { pop_path(from: name) }
      }.freeze
    end
    # rubocop: enable Metrics/AbcSize

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
          handler: ->(str) { @readings << { type: 'nanori', reading: str } } }
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
      all_type = attrs.assoc('r_type')&.at(1)
      valid = all_type&.start_with?('ja_')
      type = valid ? all_type[3..] : nil
      [valid, type]
    end

    def handle_reading(str)
      @readings << { type: @reading_type, reading: str } if @valid_reading
    end

    def start_meaning(name, attrs)
      push_path(to: name, from: :character)
      @valid_meaning = attrs.assoc('m_lang').nil?
    end

    def end_character(sym)
      pop_path(from: sym)

      record = KanjiRecord.new(
        literal: @literal,
        grade: @grade,
        stroke_count: @stroke_count,
        readings: @readings,
        meanings: @meanings
      )

      # print "#{@records.count + 1}: #{record.literal},"
      return if @readings.empty? && @meanings.empty?

      @records << record
    end

    def reset_kanji
      @literal = ''
      @grade = 0
      @stroke_count = 0
      @readings = []
      @meanings = []
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

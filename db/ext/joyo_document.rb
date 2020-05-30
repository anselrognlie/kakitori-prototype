# frozen_string_literal: true

require 'csv'
# require_relative '../app/models/jlpt_level_enum'
# require_relative '../app/models/joyo_level_enum'

module KTL
  class ParsedJoyoRecord
    attr_accessor :glyph, :gloss, :joyo, :jlpt

    def initialize(*args)
      @glyph = args[0]
      @gloss = args[3]
      @joyo = self.class.convert_joyo(args[1])
      @jlpt = self.class.convert_jlpt(args[2])
    end

    class << self
      # rubocop: disable Metrics/CyclomaticComplexity, Metrics/MethodLength
      def convert_joyo(joyo_str)
        case joyo_str
        when '1'
          JoyoLevelEnum::ONE
        when '2'
          JoyoLevelEnum::TWO
        when '3'
          JoyoLevelEnum::THREE
        when '4'
          JoyoLevelEnum::FOUR
        when '5'
          JoyoLevelEnum::FIVE
        when '6'
          JoyoLevelEnum::SIX
        when 'S'
          JoyoLevelEnum::GENERAL
        else
          JoyoLevelEnum::UNDEF
        end
      end
      # rubocop: enable Metrics/CyclomaticComplexity, Metrics/MethodLength

      # rubocop: disable Metrics/CyclomaticComplexity, Metrics/MethodLength
      def convert_jlpt(jlpt_str)
        case jlpt_str
        when '10'
          JlptLevelEnum::TEN
        when '9'
          JlptLevelEnum::NINE
        when '8'
          JlptLevelEnum::EIGHT
        when '7'
          JlptLevelEnum::SEVEN
        when '6'
          JlptLevelEnum::SIX
        when '5'
          JlptLevelEnum::FIVE
        when '4'
          JlptLevelEnum::FOUR
        when '3'
          JlptLevelEnum::THREE
        when '2.5'
          JlptLevelEnum::TWO_AND_A_HALF
        when '2'
          JlptLevelEnum::TWO
        when '1.5'
          JlptLevelEnum::ONE_AND_A_HALF
        when '1'
          JlptLevelEnum::ONE
        else
          JlptLevelEnum::UNDEF
        end
      end
      # rubocop: enable Metrics/CyclomaticComplexity, Metrics/MethodLength
    end
  end

  class JoyoDocument
    attr_reader :records

    def read(path)
      @records = CSV.foreach(path).map do |row|
        ParsedJoyoRecord.new(*row)
      end

      @records.size.positive?
    end
  end
end

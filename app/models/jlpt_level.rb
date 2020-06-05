# frozen_string_literal: true

module JlptLevelEnum
  UNDEF = 0
  TEN = 1
  NINE = 2
  EIGHT = 3
  SEVEN = 4
  SIX = 5
  FIVE = 6
  FOUR = 7
  THREE = 8
  TWO_AND_A_HALF = 9
  TWO = 10
  ONE_AND_A_HALF = 11
  ONE = 12
end

class JlptLevel < NamedEnum
  class << self
    # rubocop: disable Metrics/MethodLength
    def all
      @all ||= [
        JlptLevel.new(JlptLevelEnum::UNDEF, 'invalid'),
        JlptLevel.new(JlptLevelEnum::TEN, '10'),
        JlptLevel.new(JlptLevelEnum::NINE, '9'),
        JlptLevel.new(JlptLevelEnum::EIGHT, '8'),
        JlptLevel.new(JlptLevelEnum::SEVEN, '7'),
        JlptLevel.new(JlptLevelEnum::SIX, '6'),
        JlptLevel.new(JlptLevelEnum::FIVE, '5'),
        JlptLevel.new(JlptLevelEnum::FOUR, '4'),
        JlptLevel.new(JlptLevelEnum::THREE, '3'),
        JlptLevel.new(JlptLevelEnum::TWO_AND_A_HALF, '2.5'),
        JlptLevel.new(JlptLevelEnum::TWO, '2'),
        JlptLevel.new(JlptLevelEnum::ONE_AND_A_HALF, '1.5'),
        JlptLevel.new(JlptLevelEnum::ONE, '1')
      ]
    end
    # rubocop: enable Metrics/MethodLength
  end
end

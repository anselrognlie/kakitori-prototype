# frozen_string_literal: true

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

# frozen_string_literal: true

module KankenLevelEnum
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

class KankenLevel < NamedEnum
  class << self
    # rubocop: disable Metrics/MethodLength
    def all
      @all ||= [
        KankenLevel.new(KankenLevelEnum::UNDEF, 'invalid'),
        KankenLevel.new(KankenLevelEnum::TEN, '10'),
        KankenLevel.new(KankenLevelEnum::NINE, '9'),
        KankenLevel.new(KankenLevelEnum::EIGHT, '8'),
        KankenLevel.new(KankenLevelEnum::SEVEN, '7'),
        KankenLevel.new(KankenLevelEnum::SIX, '6'),
        KankenLevel.new(KankenLevelEnum::FIVE, '5'),
        KankenLevel.new(KankenLevelEnum::FOUR, '4'),
        KankenLevel.new(KankenLevelEnum::THREE, '3'),
        KankenLevel.new(KankenLevelEnum::TWO_AND_A_HALF, '2.5'),
        KankenLevel.new(KankenLevelEnum::TWO, '2'),
        KankenLevel.new(KankenLevelEnum::ONE_AND_A_HALF, '1.5'),
        KankenLevel.new(KankenLevelEnum::ONE, '1')
      ]
    end
    # rubocop: enable Metrics/MethodLength
  end
end

# frozen_string_literal: true

module JoyoLevelEnum
  UNDEF = 0
  ONE = 1
  TWO = 2
  THREE = 3
  FOUR = 4
  FIVE = 5
  SIX = 6
  GENERAL = 7
end

class JoyoLevel < NamedEnum
  class << self
    def all
      @all ||= [
        JoyoLevel.new(JoyoLevelEnum::UNDEF, 'invalid'),
        JoyoLevel.new(JoyoLevelEnum::ONE, '1'),
        JoyoLevel.new(JoyoLevelEnum::TWO, '2'),
        JoyoLevel.new(JoyoLevelEnum::THREE, '3'),
        JoyoLevel.new(JoyoLevelEnum::FOUR, '4'),
        JoyoLevel.new(JoyoLevelEnum::FIVE, '5'),
        JoyoLevel.new(JoyoLevelEnum::SIX, '6'),
        JoyoLevel.new(JoyoLevelEnum::GENERAL, 'general')
      ]
    end
  end
end

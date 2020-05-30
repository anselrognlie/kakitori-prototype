# frozen_string_literal: true

class JoyoLevel
  attr_reader :id, :name

  def initialize(id, name)
    @id = id
    @name = name
  end

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

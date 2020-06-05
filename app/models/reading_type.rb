# frozen_string_literal: true

module ReadingTypeEnum
  UNDEF = 0
  ON = 1
  KUN = 2
  NANORI = 3
end

class ReadingType < NamedEnum
  class << self
    def all
      @all ||= [
        ReadingType.new(ReadingTypeEnum::UNDEF, 'invalid'),
        ReadingType.new(ReadingTypeEnum::ON, 'on'),
        ReadingType.new(ReadingTypeEnum::KUN, 'kun'),
        ReadingType.new(ReadingTypeEnum::NANORI, 'nanori')
      ]
    end
  end
end

# frozen_string_literal: true

class JlptLevel < SeededEnumRecord
  self.table_name = 'jlpt_levels'

  class << self
    # rubocop: disable Metrics/MethodLength
    def seed_db
      results = nil
      seed do
        results = JlptLevel.create(
          [
            { id: JlptLevelEnum::UNDEF, label: 'invalid' },
            { id: JlptLevelEnum::TEN, label: '10' },
            { id: JlptLevelEnum::NINE, label: '9' },
            { id: JlptLevelEnum::EIGHT, label: '8' },
            { id: JlptLevelEnum::SEVEN, label: '7' },
            { id: JlptLevelEnum::SIX, label: '6' },
            { id: JlptLevelEnum::FIVE, label: '5' },
            { id: JlptLevelEnum::FOUR, label: '4' },
            { id: JlptLevelEnum::THREE, label: '3' },
            { id: JlptLevelEnum::TWO_AND_A_HALF, label: '2.5' },
            { id: JlptLevelEnum::TWO, label: '2' },
            { id: JlptLevelEnum::ONE_AND_A_HALF, label: '1.5' },
            { id: JlptLevelEnum::ONE, label: '1' }
          ]
        )
      end

      results
    end
    # rubocop: enable Metrics/MethodLength
  end
end

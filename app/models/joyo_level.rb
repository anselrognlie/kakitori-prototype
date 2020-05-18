# frozen_string_literal: true

class JoyoLevel < SeededEnumRecord
  self.table_name = 'joyo_levels'

  class << self
    # rubocop: disable Metrics/MethodLength
    def seed_db
      seed do
        JoyoLevel.create(
          [
            { id: JoyoLevelEnum::UNDEF, label: 'invalid' },
            { id: JoyoLevelEnum::ONE, label: '1' },
            { id: JoyoLevelEnum::TWO, label: '2' },
            { id: JoyoLevelEnum::THREE, label: '3' },
            { id: JoyoLevelEnum::FOUR, label: '4' },
            { id: JoyoLevelEnum::FIVE, label: '5' },
            { id: JoyoLevelEnum::SIX, label: '6' },
            { id: JoyoLevelEnum::GENERAL, label: 'general' }
          ]
        )
      end
    end
    # rubocop: enable Metrics/MethodLength
  end
end

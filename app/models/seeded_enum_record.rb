# frozen_string_literal: true

class SeededEnumRecord < ApplicationRecord
  before_destroy { |_record| raise ReadOnlyRecord }

  def readonly?
    !self.class.seeding?
  end

  class << self
    @seeding = false

    def seed
      @seeding = true
      yield
      @seeding = false
    end

    def seeding?
      @seeding
    end
  end
end

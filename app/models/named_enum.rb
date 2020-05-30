# frozen_string_literal: true

class NamedEnum
  attr_reader :id, :name

  def initialize(id, name)
    @id = id
    @name = name
  end

  class << self
    def find_by_id(id)
      @lookup ||= build_lookup
      @lookup[id]
    end

    def build_lookup
      lookup = {}
      all.each do |rec|
        lookup[rec.id] = rec
      end
      lookup
    end

    def name(id)
      find_by_id(id).name
    end
  end
end

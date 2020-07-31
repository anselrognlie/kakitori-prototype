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
      @lookup[:id][id]
    end

    def build_lookup
      id_lookup = {}
      name_lookup = {}
      all.each do |rec|
        id_lookup[rec.id] = rec
        name_lookup[rec.name] = rec
      end
      { id: id_lookup, name: name_lookup }
    end

    def name(id)
      find_by_id(id).name
    end

    def find_by_name(name)
      @lookup ||= build_lookup
      @lookup[:name][name]
    end

    def id(name)
      find_by_name(name).id
    end

    def restrict(name)
      find_by_name(name)&.name
    end
  end
end

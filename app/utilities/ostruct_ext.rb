# frozen_string_literal: true

require 'ostruct'

class OstructExt; end

class OpenStruct
  class << self
    def unpack_hash(hash)
      return OpenStruct.new unless hash

      hash = hash.dup
      hash.each do |key, value|
        hash[key] = OpenStruct.unpack_hash(value) if value.class == Hash
      end

      OpenStruct.new(hash)
    end
  end
end

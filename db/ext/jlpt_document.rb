# frozen_string_literal: true

require 'csv'

module KTL
  class ParsedJlptRecord
    attr_accessor :glyph, :level

    def initialize(*args)
      @glyph = args[0]
      @level = args[1]
    end
  end

  class JlptDocument
    attr_reader :records

    def read(path)
      @records = CSV.foreach(path).map do |row|
        ParsedJlptRecord.new(*row)
      end

      @records.size.positive?
    end
  end
end

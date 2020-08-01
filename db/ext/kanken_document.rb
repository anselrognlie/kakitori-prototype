# frozen_string_literal: true

require 'csv'
require 'joyo_level'
require 'jlpt_level'

module KTL
  class ParsedKankenRecord
    attr_accessor :glyph, :gloss, :level

    def initialize(*args)
      @glyph = args[0]
      @gloss = self.class.split_gloss(args[2])
      @level = args[1]
    end

    class << self
      def split_gloss(gloss_str)
        gloss_str.split(/,/).map(&:strip)
      end
    end
  end

  class KankenDocument
    attr_reader :records

    def read(path)
      @records = CSV.foreach(path).map do |row|
        ParsedKankenRecord.new(*row)
      end

      @records.size.positive?
    end
  end
end

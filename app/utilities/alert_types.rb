# frozen_string_literal: true

class AlertTypes
  def initialize(flash)
    @flash = flash
  end

  def status?
    AlertTypes.all.each do |s|
      return true if @flash[s]
    end

    false
  end

  def each
    AlertTypes.all.each do |s|
      message = @flash[s]
      yield s, message if message
    end
  end

  def details
    @flash[:details]&.each do |s|
      yield s
    end
  end

  def details?
    !@flash[:details].nil?
  end

  def self.all
    %w[success warning error]
  end
end

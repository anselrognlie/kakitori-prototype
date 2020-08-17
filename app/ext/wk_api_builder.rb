# frozen_string_literal: true

class WkApiBuilder
  def build(token)
    WkApi.new(token)
  end
end

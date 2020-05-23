# frozen_string_literal: true

class ValidationConverter
  def self.to_s_a(err_msgs)
    err_msgs.find_all { |rec| rec[1].count.positive? }
            .map do |rec|
              "#{rec[0].to_s.capitalize.gsub(/_/, ' ')}: #{rec[1].join(', ')}"
            end
  end
end

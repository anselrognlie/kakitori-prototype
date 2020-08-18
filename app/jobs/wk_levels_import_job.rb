# frozen_string_literal: true

class WkLevelsImportJob < ApplicationJob
  queue_as :default

  def perform(*args); end
end

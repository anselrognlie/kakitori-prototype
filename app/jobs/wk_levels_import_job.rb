# frozen_string_literal: true

class WkLevelsImportJob < ApplicationJob
  queue_as :default

  def perform(*args)
    task = WkUpdateTask.new
    task.run(api_key: args[0])
  end
end

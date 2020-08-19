# frozen_string_literal: true

class WkLevelsImportJob < ApplicationJob
  queue_as :default

  TASK_ID = 'task.wk_levels_import'

  def perform(*_args)
    task = Task.create_single(task_type: TASK_ID)
    return unless task

    do_import
  ensure
    task&.complete_single
  end

  private

  def do_import
    subscription = WkSubscription.first
    if subscription
      max_level = subscription.max_level
      api = WkApi.new(subscription.token)
      importer = WkImporter.new
      importer.import(api: api, max_level: max_level)
    else
      # clean up wk source
      importer = WkImporter.new
      importer.cleanup
    end
  end
end

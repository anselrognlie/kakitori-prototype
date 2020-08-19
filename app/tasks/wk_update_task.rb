# frozen_string_literal: true

class WkUpdateTask
  TASK_ID = 'task.wk_levels_import'

  def self.running?
    Task.running?(task_type: TASK_ID)
  end

  def self.lock
    Task.create_single(task_type: TASK_ID)
  end

  def initialize(api_builder: nil, importer: nil, registration: nil)
    @api_builder = api_builder || WkApiBuilder.new
    @importer = importer || WkImporter.new
    @registration = registration || WkRegistration.new
  end

  def run(api_key: nil)
    @api_key = api_key || ''

    do_import
  ensure
    Task.complete_single(task_type: TASK_ID)
  end

  private

  def do_import
    api = @api_builder.build(@api_key)
    subscription = @registration.register(@api_key, api)

    if @api_key.empty? || !subscription
      @importer.cleanup
    else
      max_level = subscription.max_level
      @importer.import(api: api, max_level: max_level)
    end
  end
end

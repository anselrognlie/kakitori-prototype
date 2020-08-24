# frozen_string_literal: true

class WkUpdateTask
  TASK_ID = 'task.wk_levels_import'

  def self.running?
    Task.running?(task_type: TASK_ID)
  end

  def self.lock
    Task.create_single(task_type: TASK_ID)
  end

  def self.broadcast_status
    state = {}
    render_service = SettingsRetrievalService.new(controller: state)
    render_service.call
    data = make_data(state)
    ActionCable.server.broadcast WkUpdateChannel::CHANNEL_ID, data
  end

  def self.make_data(state)
    state.instance_variables.each_with_object({}) do |ivar, data|
      cleaned = ivar.to_s[1..].to_sym
      data[cleaned] = state.instance_variable_get(ivar)
    end
  end

  def initialize(api_builder: nil, importer: nil, registration: nil)
    @api_builder = api_builder || WkApiBuilder.new
    @importer = importer || WkImporter.new
    @registration = registration || WkRegistration.new
  end

  def run(api_key: nil)
    @api_key = api_key || ''
    do_task
  ensure
    self.class.broadcast_status
  end

  private

  def do_task
    do_import
  ensure
    Task.complete_single(task_type: TASK_ID)
  end

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

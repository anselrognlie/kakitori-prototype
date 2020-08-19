# frozen_string_literal: true

class SettingsUpdateService
  def initialize(controller:, registration: nil, scheduler: nil,
                 api_builder: nil, path_helpers: nil)
    @controller = controller
    @registration = registration || WkRegistration.new
    @scheduler = scheduler || WkUpdateScheduler.new
    @api_builder = api_builder || WkApiBuilder.new
    @path_helpers = path_helpers || Rails.application.routes.url_helpers
  end

  def call
    # did the api_key change?
    load_params

    if @api_key == @curr_token
      @controller.flash[:info] = 'Attempt to set key to current token ignored.'
    elsif @api_key != @api_key_orig
      @scheduler.schedule(api_key: @api_key)
    end

    @controller.redirect_to @path_helpers.settings_path
  end

  private

  def params
    @controller.params
  end

  def api_key_params
    params
      .require(:settings).permit(:api_token, :api_token_orig)
      .merge(params.permit(:commit, :clear_token))
  end

  def load_params
    p = api_key_params
    @api_key_orig = p[:api_token_orig]
    @do_commit = !p[:commit].nil?
    @do_clear_token = !p[:clear_token].nil?
    @curr_token = WkSubscription.first&.token || ''

    @api_key = @do_clear_token ? '' : p[:api_token]
  end
end

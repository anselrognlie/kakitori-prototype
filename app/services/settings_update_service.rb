# frozen_string_literal: true

class SettingsUpdateService
  def initialize(controller, registration, retrieval_service, api_builder)
    @controller = controller
    @registration = registration
    @retrieval_service = retrieval_service
    @api_builder = api_builder
  end

  def call
    # did the api_key change?
    load_params

    if @api_key == @curr_token
      @controller.flash.now[:info] = 'Attempt to set key to current token ignored.'
    elsif @api_key != @api_key_orig
      register_token(@api_key)
      WkLevelsImportJob.perform_later
    end

    @retrieval_service.call
  end

  private

  def register_token(api_key)
    api = @api_builder.build(api_key)
    if @registration.register(api_key, api)
      @controller.flash.now[:success] = 'Updated'
    else
      @controller.flash.now[:danger] = 'Failed'
    end
  end

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

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
    p = api_key_params
    api_key = p[:api_token]
    api_key_orig = p[:api_token_orig]

    register_token(api_key) unless api_key == api_key_orig

    @retrieval_service.call
  end

  private

  def register_token(api_key)
    api = @api_builder.build(api_key)
    if @registration.register(api_key, api)
      @controller.flash.now[:success] = 'Updated'
    else
      @controller.flash.now[:error] = 'Failed'
    end
  end

  def params
    @controller.params
  end

  def api_key_params
    params.require(:settings).permit(:api_token, :api_token_orig)
  end
end

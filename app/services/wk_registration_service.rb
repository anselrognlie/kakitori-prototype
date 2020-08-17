# frozen_string_literal: true

class WkRegistrationService
  def initialize(controller, registration, api_builder)
    @controller = controller
    @registration = registration
    @api_builder = api_builder
  end

  def call
    token = token_param
    api = @api_builder.build(token)
    if @registration.register(token, api)
      @controller.render json: { status: :ok }, status_code: 200
    else
      @controller.render json: { error: {} }, status_code: 400
    end
  end

  def params
    @controller.params
  end

  def token_param
    params.require(:token)
  end
end

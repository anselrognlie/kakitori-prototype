# frozen_string_literal: true

class WkRegistrationService
  def initialize(controller, api)
    @controller = controller
    @api = api
  end

  # rubocop: disable Metrics/MethodLength
  def call
    # contact wk api using token (dep) to retrieve subscription settings
    user = @api.query_user_data
    subscription = user.subscription
    unless subscription.nil?
      record = WkSubscription.new(username: user.username, token: @api.token,
                                  active: subscription.active, type: subscription.type,
                                  max_level: subscription.max_level_granted,
                                  end_of_subscription: subscription.period_ends_at)
      if record.save
        @controller.render json: { status: :ok }, status_code: 200
        return
      end
    end

    @controller.render json: { error: {} }, status_code: 400
  end
  # rubocop: enable Metrics/MethodLength
end

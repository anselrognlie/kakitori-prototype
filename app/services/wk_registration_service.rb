# frozen_string_literal: true

class WkRegistrationService
  def initialize(controller, api, token)
    @controller = controller
    @api = api
    @token = token
  end

  def call
    # contact wk api using token (dep) to retrieve subscription settings
    user = @api.query_user_data
    subscription = user.subscription
    unless subscription.nil?
      record = self.class.prepare_record(user, subscription, @token)
      if record.save
        @controller.render json: { status: :ok }, status_code: 200
        return
      end
    end

    @controller.render json: { error: {} }, status_code: 400
  end

  def self.prepare_record(user, subscription, token)
    # do we already have an entry for the token?
    record = WkSubscription.where(token: token).first
    if record
      record.update_from_subscription(user, subscription)
    else
      record = WkSubscription.make_from_subscription(token, user, subscription)
    end

    record
  end
end

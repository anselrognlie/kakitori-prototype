# frozen_string_literal: true

class WkRegistration
  def register(token, api)
    # contact wk api using token (dep) to retrieve subscription settings
    user = api.query_user_data
    subscription = user.subscription

    return false if subscription.nil?

    record = self.class.prepare_record(user, subscription, token)
    record.save
  end

  def self.prepare_record(user, subscription, token)
    # do we already have a token?
    record = WkSubscription.first
    if record
      record.update_from_subscription(token, user, subscription)
    else
      record = WkSubscription.make_from_subscription(token, user, subscription)
    end

    record
  end
end

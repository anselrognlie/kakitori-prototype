# frozen_string_literal: true

class WkSubscription < ApplicationRecord
  self.inheritance_column = 'not_sti'

  def update_from_subscription(token, user, subscription)
    self.token = token
    self.username = user.username
    self.active = subscription.active
    self.type = subscription.type
    self.max_level = subscription.max_level_granted
    self.end_of_subscription = subscription.period_ends_at
  end

  def self.make_from_subscription(token, user, subscription)
    WkSubscription.new(
      username: user.username, token: token,
      active: subscription.active, type: subscription.type,
      max_level: subscription.max_level_granted,
      end_of_subscription: subscription.period_ends_at
    )
  end
end

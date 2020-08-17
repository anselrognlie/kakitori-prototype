# frozen_string_literal: true

class SubscriptionSummarySerializer
  def to_s(subscription)
    status = status_str(subscription)
    type = type_str(subscription)
    renews = renews_str(subscription)
    level = level_str(subscription)
    "Account: #{subscription.username} (#{status} #{level} #{type}#{renews})"
  end

  private

  def status_str(subscription)
    subscription.active ? 'active' : 'inactive'
  end

  def type_str(subscription)
    "#{subscription.type} subscription"
  end

  def level_str(subscription)
    "level #{subscription.max_level}"
  end

  def renews_str(subscription)
    return '' unless subscription.end_of_subscription

    " expiring #{subscription.end_of_subscription.strftime('%Y-%m-%d')}"
  end
end

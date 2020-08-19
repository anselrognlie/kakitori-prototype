# frozen_string_literal: true

class SettingsRetrievalService
  RUNNING_TOKEN = '*' * 24
  RUNNING_DESCRIPTION = 'Subscription information is currently being updated.  ' \
                        'Refresh to check status.'

  def initialize(controller:, serializer: nil, injector: nil)
    @controller = controller
    @serializer = serializer || SubscriptionSummarySerializer.new
    @injector = injector || DataInjector.new
  end

  def call
    @update_running = WkUpdateTask.running?

    # get current subscription info
    @info = WkSubscription.first
    return unless @info || @update_running

    display_token = make_display_token
    subscription_str = make_description

    ivars = {
      :@api_token => display_token,
      :@subscription_info => subscription_str
    }
    @injector.inject_as_ivars(ivars, @controller)
  end

  private

  def make_display_token
    @update_running ? RUNNING_TOKEN : "#{@info.token[0, 4]}#{'*' * (@info.token.length - 4)}"
  end

  def make_description
    @update_running ? RUNNING_DESCRIPTION : @serializer.to_s(@info)
  end
end

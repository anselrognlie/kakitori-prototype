# frozen_string_literal: true

class SettingsRetrievalService
  def initialize(controller, serializer, injector)
    @controller = controller
    @serializer = serializer
    @injector = injector
  end

  def call
    # get current subscription info
    info = WkSubscription.first
    return unless info

    display_token = "#{info.token[0, 4]}#{'*' * (info.token.length - 4)}"
    subscription_str = @serializer.to_s(info)

    ivars = {
      :@api_token => display_token,
      :@subscription_info => subscription_str
    }
    @injector.inject_as_ivars(ivars, @controller)
  end
end

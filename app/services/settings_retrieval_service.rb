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
    @info = WkSubscription.first

    done = make_enabled
    ivars = {
      :@api_token => make_display_token,
      :@details => make_description,
      :@submit_enabled => done,
      :@done => done
    }

    @injector.inject_as_ivars(ivars, @controller)
  end

  private

  def make_display_token
    return RUNNING_TOKEN if @update_running

    @info ? "#{@info.token[0, 4]}#{'*' * (@info.token.length - 4)}" : ''
  end

  def make_description
    return RUNNING_DESCRIPTION if @update_running

    @info ? @serializer.to_s(@info) : ''
  end

  def make_enabled
    !@update_running
  end
end

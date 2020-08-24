# frozen_string_literal: true

class WkUpdateChannel < ApplicationCable::Channel
  CHANNEL_ID = 'wk_update'

  def subscribed
    # stream_from "some_channel"
    stream_from CHANNEL_ID
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(_data: nil)
    # check whether the update task is still running
    WkUpdateTask.broadcast_status
  end
end

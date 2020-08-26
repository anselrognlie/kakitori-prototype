import { Connection } from "@rails/actioncable";
import consumer from "./consumer"

export default (channelName, mixin) => {
  const dcState = {
    isConnected: false,
    queuedData: [],
    connected: mixin.connected,
    channel: null,
    send: null
  };

  mixin.connected = function() {
    dcState.isConnected = true;
    dcState.connected.call(this);

    const queuedData = dcState.queuedData;
    const channel = dcState.channel;
    while (queuedData.length) {
      const data = queuedData.shift();
      dcState.send.call(channel, data);
    }
  };

  const channel = consumer.subscriptions.create(channelName, mixin);
  dcState.channel = channel;
  dcState.send = channel.send;

  channel.send = function(data) {
    if (dcState.isConnected) {
      return dcState.send.call(channel, data);
    }

    dcState.queuedData.push(data);
    return true;
  };

  return channel;
};
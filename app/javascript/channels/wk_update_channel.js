import makeDelayedConsumer from "./delayed_consumer"
import Settings from '../sitewide/settings';

const wkUpdateChannel = makeDelayedConsumer("WkUpdateChannel", {

  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    const done = data.hasOwnProperty('done') ? data.done : false;
    if (! done) { return; }

    const api_token = data.api_token;
    const details = data.details;

    Settings.update({ api_token, details });
  }
});

export default () => {
  return wkUpdateChannel;
};

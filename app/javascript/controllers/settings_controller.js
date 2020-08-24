import { Controller } from "stimulus";
import makeSender from '../channels/wk_update_channel';

export default class extends Controller {
  connect() {
    console.log('settings-form');
    const sender = makeSender();
    sender.send({})
  }
}
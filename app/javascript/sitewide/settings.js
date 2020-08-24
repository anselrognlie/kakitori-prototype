import $ from 'jquery';

class Settings {};

Settings.update = ({ api_token, details }) => {
  const form_done_field = $('input[name="settings_form_done"]');
  const form_done = form_done_field.value === 'true';
  if (form_done) { return; }

  const token_field = $('input[name="settings[api_token]"]');
  const clear_token_button = $('input[name="clear_token"]');
  const details_div = $('div.details');
  const orig_token_field = $('input[name="settings[orig_api_token]"]');
  const commit_button = $('input[name="commit"]');

  token_field.attr('value', api_token);
  orig_token_field.attr('value', api_token);
  details_div.text(details);
  clear_token_button.attr('disabled', false);
  commit_button.attr('disabled', false);
  form_done_field.attr('value', true);
};

export default Settings;
$(document).on('ajax:before', '[data-remote]', () => {
  Turbolinks.clearCache();
});

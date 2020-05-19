$('document').ready(() => {
  const dd = $('span.nav_header__user--dropdown');
  const menu = dd.parent().children('div.nav_header__user--menu');
  dd.click(() => {
    menu.css('display', 'block');
  });
});
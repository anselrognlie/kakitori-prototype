$(document).on('turbolinks:load', () => {
  console.log('ready');
  const dd = $('span.nav_header__user--dropdown').parent();
  const menu = dd.children('div.nav_header__user--menu');
  dd.mouseover(() => {
    menu.css('display', 'block');
  });

  menu.mouseleave(() => {
    menu.css('display', 'none');
  });
});
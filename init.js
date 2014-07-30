onload = function() {
  global.gui = require('nw.gui');
  global.window = window;
  global.$ = $;
  require('coffee-script/register');
  require('./app.coffee');
  global.gui.Window.get().show();
};
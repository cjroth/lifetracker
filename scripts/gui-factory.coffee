angular
  .module 'lifetracker'
  .factory 'gui', ->
    return require('nw.gui');

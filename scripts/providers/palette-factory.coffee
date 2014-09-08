angular
  .module 'lifetracker'
  .factory 'palette', ->
    return new Rickshaw.Color.Palette(scheme: 'colorwheel')
    
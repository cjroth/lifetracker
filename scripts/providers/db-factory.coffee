angular
  .module 'lifetracker'
  .factory 'db', ->
    
    return new Nedb(autoload: true)

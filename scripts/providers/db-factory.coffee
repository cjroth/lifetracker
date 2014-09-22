angular
  .module 'lifetracker'
  .factory 'db', ->

    path = require('path')
    nedb = require('nedb')
    gui = require('nw.gui')

    filename = path.join(gui.App.dataPath, 'data.db')
    console.debug('using database: ' + filename)
    return new nedb(filename: filename, autoload: true)

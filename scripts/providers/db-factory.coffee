angular
  .module 'lifetracker'
  .factory 'db', ->

    path = require('path')
    sqlite3 = require('sqlite3').verbose()
    gui = require('nw.gui')
    dbs = {}

    db = (dataLocation) ->
      dataLocation = path.resolve(gui.App.dataPath, dataLocation)
      dbs[dataLocation]

    db.add = (dataLocation, done) ->
      dataLocation = path.resolve(gui.App.dataPath, dataLocation)
      console.debug('adding database: ' + dataLocation)
      database = new sqlite3.Database(dataLocation)
      database.run 'create table if not exists variables (name text, type text, min float, max float, question text, units text, deleted_at text)'
      database.run 'create table if not exists records (variable_id integer, value float, date text, deleted_at text)', ->
        database.run 'create unique index if not exists daily on records (variable_id, date desc)', ->
          dbs[dataLocation] = database
          done?()

    return db
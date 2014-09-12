angular
  .module 'lifetracker'
  .factory 'db', ->

    sqlite3 = require('sqlite3').verbose()
    dbs = {}

    db = (dataLocation) -> dbs[dataLocation]

    db.add = (dataLocation, done) ->

      database = new sqlite3.Database(dataLocation)

      database.run 'create table if not exists variables (name text, type text, min float, max float, question text, units text, deleted_at text)'
      database.run 'create table if not exists records (variable_id integer, value float, date text, deleted_at text)', ->
        database.run 'create unique index if not exists daily on records (variable_id, date desc)', ->
          dbs[dataLocation] = database
          done?()

    return db
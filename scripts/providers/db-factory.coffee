angular
  .module 'lifetracker'
  .factory 'db', ->

    dbs = {}

    return (dataLocation) ->

      if not dbs[dataLocation]?

        sqlite3 = require('sqlite3').verbose()
        db = new sqlite3.Database(dataLocation)

        db.run 'create table if not exists variables (name text, type text, min float, max float, question text, units text, deleted_at text)'
        db.run 'create table if not exists records (variable_id integer, value float, date text, deleted_at text)' 
        db.run 'create unique index if not exists daily on records (variable_id, date desc)'

        dbs[dataLocation] = db

      return dbs[dataLocation]

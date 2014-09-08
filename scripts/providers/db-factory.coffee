angular
  .module 'lifetracker'
  .factory 'db', ->

    sqlite3 = require('sqlite3').verbose()
    db = new sqlite3.Database('data/database.sqlite')

    db.run 'create table if not exists variables (name text, type text, min float, max float, question text, units text, deleted_at)'
    db.run 'create table if not exists records (variable_id integer, value float, timestamp timestamp, deleted_at timestamp)' 

    return db
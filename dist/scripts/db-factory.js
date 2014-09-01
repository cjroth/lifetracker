angular.module('lifetracker').factory('db', function() {
  var db, sqlite3;
  sqlite3 = require("sqlite3").verbose();
  db = new sqlite3.Database("data/database.sqlite");
  db.run("CREATE TABLE if not exists variables (name TEXT, type TEXT, min FLOAT, max FLOAT, question TEXT, units TEXT, deleted_at)");
  db.run("CREATE TABLE if not exists records (variable_id INTEGER, value FLOAT, timestamp TIMESTAMP, deleted_at TIMESTAMP)");
  return db;
});

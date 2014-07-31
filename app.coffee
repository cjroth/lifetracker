gui = require('nw.gui');
sqlite3 = require("sqlite3").verbose()
db = new sqlite3.Database("data/database.sqlite")
jade = require("jade")
fs = require("fs")
$ = window.jQuery

$("body").html jade.renderFile("views/app.jade")
$("select").selecter()

createVariable = (variable, done) ->
  statement = db.prepare("INSERT INTO variables VALUES ($name, $type, $min, $max)")
  statement.run variable
  statement.finalize(done)

createRecord = (record, done) ->
  statement = db.prepare("INSERT INTO records VALUES ($variable_id, $value, $timestamp)")
  statement.run record
  statement.finalize(done)

getVariables = (done) ->
  db.all "SELECT rowid id, * FROM variables", done

getEachVariable = (done) ->
  db.each "SELECT rowid id, * FROM variables", done

getRecords = (done) ->
  db.all "SELECT rowid id, * FROM records", done

getEachRecord = (done) ->
  db.each "SELECT rowid id, * FROM records", done

db.serialize ->

  db.run "CREATE TABLE if not exists variables (name TEXT, type TEXT, min FLOAT, max FLOAT)"
  db.run "CREATE TABLE if not exists records (variable_id INTEGER, value FLOAT, timestamp INTEGER)"

  # createVariable
  #   $name: "Sleep"
  #   $type: "boolean"

  # createRecord
  #   $variable_id: 1
  #   $value: 8.5
  #   $timestamp: new Date().getTime()

  getVariables (err, variables) ->
    $(".sidebar").html jade.renderFile("views/sidebar.jade", variables: variables)

  # getEachVariable (err, variable) ->
  #   console.log 'var', arguments

  # getEachRecord (err, record) ->
  #   console.log 'record', arguments

db.close()
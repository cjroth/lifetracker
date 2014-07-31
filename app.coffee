gui = require('nw.gui');

sqlite3 = require("sqlite3").verbose()
db = new sqlite3.Database(":memory:")
jade = require("jade")

$("body").html jade.renderFile("app.jade")

db.serialize ->

  db.run "CREATE TABLE variables (name TEXT, type TEXT, min FLOAT, max FLOAT)"

  statement = db.prepare("INSERT INTO variables VALUES ($name, $type, $min, $max)")
  statement.run
    $name: "Sleep"
    $type: "float"
    $min: 0
    $max: 24
  statement.finalize()

  db.each "SELECT rowid id, name, type, min, max FROM variables", (err, row) ->

db.close()
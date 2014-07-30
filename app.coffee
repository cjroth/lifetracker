sqlite3 = require("sqlite3").verbose()
db = new sqlite3.Database(":memory:")
win = require("nw.gui").Window.get()

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

resizeApp = (width, height) ->
  $(".app")
    .width width
    .height height

# window.onload = ->
# win.show()
win.on "resize", resizeApp
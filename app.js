var sqlite3 = require('sqlite3').verbose();
var db = new sqlite3.Database(':memory:');

db.serialize(function() {

  db.run('CREATE TABLE variables (name TEXT, type TEXT, min FLOAT, max FLOAT)');

  var statement = db.prepare('INSERT INTO variables VALUES ($name, $type, $min, $max)');
  statement.run({
    $name: 'Sleep',
    $type: 'float',
    $min: 0,
    $max: 24,
  });
  statement.finalize();

  db.each('SELECT rowid id, name, type, min, max FROM variables', function(err, row) {
    // document.write(JSON.stringify(row));
  });

});

db.close();

window.onload = function() {
  require('nw.gui').Window.get().show();
};
angular.module('lifetracker').factory('store', function(db) {
  var store;
  store = {
    createVariable: function(data, done) {
      var statement;
      statement = db.prepare("insert into variables values ($name, $type, $min, $max, $question, $units, null)");
      statement.run({
        $name: data.name,
        $question: data.question,
        $type: data.type,
        $min: data.min,
        $max: data.max,
        $units: data.units
      });
      return statement.finalize(done);
    },
    deleteVariable: function(id, done) {
      var statement;
      statement = db.prepare("update variables set deleted_at = $deleted_at where rowid = $id");
      statement.run({
        $id: id,
        $deleted_at: (new Date).getTime()
      });
      return statement.finalize(done);
    },
    updateVariable: function(id, data, done) {
      var statement;
      statement = db.prepare("update variables set name = $name, question = $question where rowid = $id");
      statement.run({
        $id: id,
        $name: data.name,
        $question: data.question
      });
      return statement.finalize(done);
    },
    createRecord: function(data, done) {
      var statement;
      statement = db.prepare("insert into records values ($variable_id, $value, $timestamp, null)");
      statement.run({
        $variable_id: data.variable_id,
        $value: data.value,
        $timestamp: data.timestamp || (new Date).getTime()
      });
      return statement.finalize(done);
    },
    getVariables: function(done) {
      return db.all("select rowid id, * from variables where deleted_at is null order by name asc", function(err, vars) {
        var variable, variables, _i, _len, _results;
        variables = [];
        _results = [];
        for (_i = 0, _len = vars.length; _i < _len; _i++) {
          variable = vars[_i];
          variables.push(variable);
          _results.push(done(err, variables));
        }
        return _results;
      });
    },
    getEachVariable: function(done) {
      return db.each("select rowid id, * from variables where deleted_at is null order by name asc", done);
    },
    getRecords: function(done) {
      return db.all("select rowid id, * from records where deleted_at is null", done);
    },
    getEachRecord: function(done) {
      return db.each("select rowid id, * from records where deleted_at is null", done);
    }
  };
  return store;
});

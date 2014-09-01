angular
  .module 'lifetracker'
  .factory 'store', (db) ->

    store =

      createVariable: (data, done) ->
        statement = db.prepare("insert into variables values ($name, $type, $min, $max, $question, $units, null)")
        statement.run
          $name: data.name
          $question: data.question
          $type: data.type
          $min: data.min
          $max: data.max
          $units: data.units
        statement.finalize(done)

      deleteVariable: (id, done) ->
        statement = db.prepare("update variables set deleted_at = $deleted_at where rowid = $id")
        statement.run
          $id: id
          $deleted_at: (new Date).getTime()
        statement.finalize(done)

      updateVariable: (id, data, done) ->
        statement = db.prepare("update variables set name = $name, question = $question where rowid = $id")
        statement.run
          $id: id
          $name: data.name
          $question: data.question
        statement.finalize(done)

      createRecord: (data, done) ->
        statement = db.prepare("insert into records values ($variable_id, $value, $timestamp, null)")
        statement.run
          $variable_id: data.variable_id
          $value: data.value
          $timestamp: data.timestamp || (new Date).getTime()
        statement.finalize(done)

      getVariables: (done) ->
        db.all "select rowid id, * from variables where deleted_at is null order by name asc", (err, vars) ->
          variables = []
          for variable in vars
            variables.push variable
            done(err, variables)

      getEachVariable: (done) ->
        db.each "select rowid id, * from variables where deleted_at is null order by name asc", done

      getRecords: (done) ->
        db.all "select rowid id, * from records where deleted_at is null", done

      getEachRecord: (done) ->
        db.each "select rowid id, * from records where deleted_at is null", done

    return store
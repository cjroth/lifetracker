angular
  .module 'lifetracker'
  .factory 'store', (db, moment, settings) ->

    store =

      createVariable: (data, done) ->
        statement = db(settings.dataLocation).prepare('insert into variables values ($name, $type, $min, $max, $question, $units, null)')
        statement.run
          $name: data.name
          $question: data.question
          $type: data.type
          $min: data.min
          $max: data.max
          $units: data.units
        statement.finalize(done)

      deleteVariable: (id, done) ->
        statement = db(settings.dataLocation).prepare('update variables set deleted_at = $deleted_at where rowid = $id')
        statement.run
          $id: id
          $deleted_at: (new Date).getTime()
        statement.finalize(done)

      updateVariable: (id, data, done) ->
        statement = db(settings.dataLocation).prepare('update variables set name = $name, question = $question where rowid = $id')
        statement.run
          $id: id
          $name: data.name
          $question: data.question
        statement.finalize(done)

      createRecord: (data, done) ->
        statement = db(settings.dataLocation).prepare('insert into records values ($variable_id, $value, $date, null)')
        statement.run
          $variable_id: data.variable_id
          $value: data.value
          $date: data.date
        statement.finalize(done)

      updateRecord: (id, value, done) ->
        statement = db(settings.dataLocation).prepare('update records set value = $value where rowid = $id')
        statement.run
          $id: id
          $value: value
        statement.finalize(done)

      getVariables: (done) ->
        db(settings.dataLocation).all 'select rowid id, * from variables where deleted_at is null order by lower(name) asc', (err, variables) ->
          done(err, variables or [])

      getEachVariable: (done) ->
        db(settings.dataLocation).each 'select rowid id, * from variables where deleted_at is null order by name asc', done

      getRecords: (done) ->
        db(settings.dataLocation).all 'select rowid id, * from records where deleted_at is null order by date asc', (err, records) ->
          done(err, records or [])

      getRecordsForDate: (date, done) ->
        statement = db(settings.dataLocation).prepare('select rowid id, * from records where date is $date and deleted_at is null')
        statement.run($date: date)
        statement.all(done)

      getEachRecord: (done) ->
        db(settings.dataLocation).each 'select rowid id, * from records where deleted_at is null', done

    return store
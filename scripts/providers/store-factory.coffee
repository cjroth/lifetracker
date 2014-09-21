angular
  .module 'lifetracker'
  .factory 'store', (db, moment, settings) ->

    store =

      createVariable: (data, done) ->
        statement = 'insert into variables values ($name, $type, $question, $units, null)'
        params =
          $name: data.name
          $question: data.question
          $type: data.type
          $units: data.units
        db(settings.dataLocation).run(statement, params, done)

      deleteVariable: (id, done) ->
        statement = 'update variables set deleted_at = $deleted_at where rowid = $id'
        params = 
          $id: id
          $deleted_at: (new Date).getTime()
        db(settings.dataLocation).run(statement, params, done)

      updateVariable: (id, data, done) ->
        statement = 'update variables set name = $name, question = $question where rowid = $id'
        params =
          $id: id
          $name: data.name
          $question: data.question
        db(settings.dataLocation).run(statement, params, done)

      createRecord: (data, done) ->
        statement = 'insert into records values ($variable_id, $value, $date, null)'
        params =
          $variable_id: data.variable_id
          $value: data.value
          $date: data.date
        db(settings.dataLocation).run(statement, params, done)

      updateRecord: (id, value, done) ->
        statement = 'update records set value = $value where rowid = $id'
        params =
          $id: id
          $value: value
        db(settings.dataLocation).run(statement, params, done)

      deleteRecord: (id, done) ->
        statement = 'delete from records where rowid = $id'
        params =
          $id: id
        db(settings.dataLocation).run(statement, params, done)

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
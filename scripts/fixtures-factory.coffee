angular
  .module 'lifetracker'
  .factory 'fixtures', (store, db) ->

    chance = new Chance()

    return ->

      variables = [
        {
          name: 'Sleep',
          question: 'How much sleep did you get last night?'
          type: 'number'
          units: 'hours'
          min: 0
          max: 24
        },
        {
          name: 'Productivity',
          question: 'How productive were you last night?'
          type: 'scale'
        },
        {
          name: 'Income',
          question: 'How much money did you make today?'
          type: 'number'
          units: 'USD'
          min: 0
        },
      ]

      baseTime = (new Date).getTime()

      records = []

      for variable, i in variables

        moreRecords = []

        for j in [1..100]

          if variable.type is 'number'
            value = chance.integer(min: variable.min, max: variable.max || 1000)

          if variable.type is 'scale'
            value = chance.integer(min: 0, max: 10)

          moreRecords.push(
            variable_id: i + 1
            value: value
            timestamp: baseTime - 24 * 60 * 60 * 1000 * j
          )

        records = records.concat(moreRecords.reverse())

      statement = db.prepare('delete from variables;')
      statement.run()
      statement.finalize()

      statement = db.prepare('delete from records;')
      statement.run()
      statement.finalize()

      for variable in variables
        store.createVariable variable

      for record in records
        store.createRecord record
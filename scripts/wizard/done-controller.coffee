angular
  .module 'lifetracker'
  .controller 'WizardDoneController', ($scope, $state, $stateParams, store, variable) ->

    $scope.done = ->

      async.each _.toArray($scope.records), (record, done) ->

        if record.skipped then return done()

        data = 
          variable_id: record.variable.id
          value: if record.variable.type is 'boolean' then !!record.value else parseFloat record.value
          date: $stateParams.date

        if record.id?
          store.updateRecord(record.id, record.value, done)
        else
          store.createRecord(data, done)

      , (err) ->

        $state.go('default')

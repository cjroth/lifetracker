angular.module('lifetracker').controller('WizardDoneController', function($scope, $state, store, variable) {
  return $scope.done = function() {
    return async.each(_.toArray($scope.records), function(record, done) {
      var data;
      data = {
        variable_id: record.variable.id,
        value: record.variable.type === 'boolean' ? !!record.value : parseFloat(record.value)
      };
      return store.createRecord(data, done);
    }, function(err) {
      return $state.go('default');
    });
  };
});

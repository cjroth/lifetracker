angular.module('lifetracker').controller('WizardMainController', function($scope, $state, variable, variables) {
  var index, next, previous, _base;
  index = variables.indexOf(variable);
  next = variables[index + 1];
  previous = variables[index - 1];
  $scope.progress = index / variables.length * 100;
  $scope.variable = variable;
  $scope.record = $scope.records[variable.id] || {
    variable: variable
  };
  if (variable.type === 'scale') {
    if ((_base = $scope.record).value == null) {
      _base.value = 5;
    }
  }
  $scope.$watch('record', function() {
    return $scope.records[variable.id] = $scope.record;
  });
  $scope.skip = function() {
    if (next) {
      return $state.go('wizard.step', {
        id: next.id
      });
    } else {
      return $state.go('wizard.done');
    }
  };
  $scope["continue"] = function() {
    if (next) {
      return $state.go('wizard.step', {
        id: next.id
      });
    } else {
      return $state.go('wizard.done');
    }
  };
  if (previous) {
    $scope.previous = function() {
      return $state.go('wizard.step', {
        id: previous.id
      });
    };
  }
}).controller('WizardDoneController', function($scope, $state, store, variable, variables) {
  $scope.done = function() {
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

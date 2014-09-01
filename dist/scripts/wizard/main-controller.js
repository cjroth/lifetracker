angular.module('lifetracker').controller('WizardMainController', function($rootScope, $scope, $state, variable) {
  var index, next, previous, variables, _base;
  variables = $rootScope.variables;
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
    return $scope.previous = function() {
      return $state.go('wizard.step', {
        id: previous.id
      });
    };
  }
});

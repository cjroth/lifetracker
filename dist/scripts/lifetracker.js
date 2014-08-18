angular.module('lifetracker', ['ngSanitize', 'ngAnimate', 'ui.router', 'mgcrea.ngStrap', 'ui.bootstrap-slider', 'toggle-switch']);

angular.module('lifetracker').config(function($urlRouterProvider, $stateProvider) {
  return $stateProvider.state('root', {
    abstract: true,
    views: {
      'nav@': {
        templateUrl: 'templates/nav.html',
        controller: 'NavController'
      }
    }
  }).state('default', {
    parent: 'root',
    url: '/',
    views: {
      'body@': {
        templateUrl: 'templates/default/default.html'
      }
    }
  }).state('wizard', {
    parent: 'root',
    url: '/wizard',
    resolve: {
      variables: function($rootScope, store, $q) {
        var deferred;
        deferred = $q.defer();
        store.getVariables(function(err, variables) {
          return deferred.resolve(variables);
        });
        return deferred.promise;
      }
    },
    views: {
      'body@': {
        templateUrl: 'templates/wizard/wizard.html',
        controller: function($state, variables) {
          if ($state.current.name === 'wizard') {
            return $state.go('wizard.step', {
              id: variables[0].id
            });
          }
        }
      }
    }
  }).state('wizard.step', {
    url: '/:id',
    resolve: {
      variable: function($state, $rootScope, $stateParams, variables) {
        return _.findWhere(variables, {
          id: ~~$stateParams.id
        });
      }
    },
    views: {
      'main@body': {
        templateUrl: 'templates/wizard/main.html',
        controller: 'WizardMainController'
      },
      'sidebar@body': {
        templateUrl: 'templates/wizard/sidebar.html',
        controller: 'WizardSidebarController'
      }
    }
  });
}).factory('db', function() {
  var db, sqlite3;
  sqlite3 = require("sqlite3").verbose();
  db = new sqlite3.Database("data/database.sqlite");
  db.run("CREATE TABLE if not exists variables (name TEXT, type TEXT, min FLOAT, max FLOAT, question TEXT, units TEXT)");
  db.run("CREATE TABLE if not exists records (variable_id INTEGER, value FLOAT, timestamp INTEGER)");
  return db;
}).factory('store', function(db) {
  var store;
  store = {
    createVariable: function(data, done) {
      var statement;
      statement = db.prepare("insert into variables values ($name, $type, $min, $max, $question, $units)");
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
      statement = db.prepare("delete from variables where rowid = $id");
      statement.run({
        $id: id
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
    createRecord: function(record, done) {
      var statement;
      statement = db.prepare("insert into records values ($variable_id, $value, $timestamp)");
      statement.run(record);
      return statement.finalize(done);
    },
    getVariables: function(done) {
      return db.all("select rowid id, * from variables order by name asc", function(err, vars) {
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
      return db.each("select rowid id, * from variables order by name asc", done);
    },
    getRecords: function(done) {
      return db.all("select rowid id, * from records", done);
    },
    getEachRecord: function(done) {
      return db.each("select rowid id, * from records", done);
    }
  };
  return store;
}).directive('editVariable', function() {
  var link;
  link = function(scope, element, attrs) {
    var $element;
    $element = $(element);
    element.on('click', function() {});
  };
  return {
    restrict: 'A',
    link: link
  };
}).run(function($rootScope, store) {
  return store.getVariables(function(err, variables) {
    if (err) {
      return;
    }
    $rootScope.variables = variables;
    return $rootScope.$digest();
  });
}).controller('NavController', function($scope) {
  $scope.shit = {};
  $('.datepicker').datepicker({
    inputs: $('.range-start, .range-end')
  });
}).controller('DefaultSidebarController', function($scope, store) {}).controller('DefaultMainController', function($scope) {}).controller('WizardSidebarController', function($state, $scope, variable) {
  $scope.goTo = function(variable) {
    return $state.go('wizard.step', {
      id: variable.id
    });
  };
  $scope.currentVariable = variable;
}).controller('WizardMainController', function($scope, variable) {
  $scope.variable = variable;
  $scope.record = {};
}).controller('EditVariablePopoverController', function($rootScope, $scope, store) {
  $scope.form = angular.copy($scope.variable);
  return $scope.save = function() {
    return store.updateVariable($scope.form.id, $scope.form, function(err) {
      if (err) {
        return;
      }
      angular.extend($scope.variable, $scope.form);
      $scope.$hide();
      return $rootScope.$digest();
    });
  };
}).controller('DeleteVariablePopoverController', function($rootScope, $scope, store) {
  return $scope["delete"] = function() {
    return store.deleteVariable($scope.variable.id, function(err) {
      if (err) {
        return;
      }
      $rootScope.variables = _.without($rootScope.variables, $scope.variable);
      $scope.$hide();
      return $rootScope.$digest();
    });
  };
}).controller('CreateVariablePopoverController', function($rootScope, $scope, store) {
  var defaults;
  defaults = {
    type: 'scale'
  };
  $scope.variable = angular.copy(defaults);
  $scope.save = function() {
    var variable;
    variable = angular.copy($scope.variable);
    return store.createVariable(variable, function(err) {
      if (err) {
        return;
      }
      $scope.CreateVariablePopover.visible = false;
      $scope.variables.push(variable);
      $rootScope.$digest();
      return $scope.variable = angular.copy(defaults);
    });
  };
}).run(function($state) {
  return $state.go('default', {
    id: 3
  });
});

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
        templateUrl: 'templates/default/default.html',
        controller: 'DefaultMainController'
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
        controller: function($scope, $state, variables) {
          $scope.records = {};
          if ($state.current.name === 'wizard') {
            return $state.go('wizard.step', {
              id: variables[0].id
            });
          }
        }
      }
    }
  }).state('wizard.done', {
    url: '/done',
    resolve: {
      variable: function() {
        return null;
      }
    },
    views: {
      'main@body': {
        templateUrl: 'templates/wizard/done.html',
        controller: 'WizardDoneController'
      },
      'sidebar@body': {
        templateUrl: 'templates/wizard/sidebar.html',
        controller: 'WizardSidebarController'
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
  db.run("CREATE TABLE if not exists records (variable_id INTEGER, value FLOAT, timestamp TIMESTAMP)");
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
    createRecord: function(data, done) {
      var statement;
      statement = db.prepare("insert into records values ($variable_id, $value, $timestamp)");
      statement.run({
        $variable_id: data.variable_id,
        $value: data.value,
        $timestamp: data.timestamp || (new Date).getTime()
      });
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
}).controller('NavController', function($scope, $state) {
  $scope.$state = $state;
  $('.datepicker').datepicker({
    inputs: $('.range-start, .range-end')
  });
}).controller('DefaultSidebarController', function($scope, store) {}).controller('DefaultMainController', function($scope, store, $window) {
  store.getRecords(function(err, records) {
    var colors, graph, gui, i, record, series, seriesData, timezoneOffset, variable, win, _i, _j, _k, _len, _len1, _len2, _ref, _ref1;
    colors = ['red', 'blue', 'green'];
    seriesData = {};
    series = [];
    timezoneOffset = (new Date).getTimezoneOffset() * 60;
    _ref = $scope.variables;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      variable = _ref[_i];
      seriesData[variable.id] = [];
    }
    for (_j = 0, _len1 = records.length; _j < _len1; _j++) {
      record = records[_j];
      seriesData[record.variable_id].push({
        x: record.timestamp / 1000 - timezoneOffset,
        y: record.value
      });
    }
    _ref1 = $scope.variables;
    for (i = _k = 0, _len2 = _ref1.length; _k < _len2; i = ++_k) {
      variable = _ref1[i];
      series.push({
        color: colors[i],
        data: seriesData[variable.id]
      });
    }
    graph = new Rickshaw.Graph({
      element: document.getElementById('chart'),
      width: $('.main').width(),
      height: $('.main').height(),
      renderer: 'line',
      series: series
    });
    gui = require('nw.gui');
    win = gui.Window.get().on('resize', function() {
      graph.configure({
        width: $('.main').width(),
        height: $('.main').height()
      });
      return graph.render();
    });
    new Rickshaw.Graph.Axis.Time({
      graph: graph
    });
    return graph.render();
  });
}).controller('WizardSidebarController', function($state, $scope, variable) {
  $scope.goTo = function(variable) {
    return $state.go('wizard.step', {
      id: variable.id
    });
  };
  $scope.currentVariable = variable;
}).controller('WizardMainController', function($scope, $state, variable, variables) {
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

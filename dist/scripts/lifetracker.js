angular.module('lifetracker', ['ngSanitize', 'ngAnimate', 'ui.router', 'mgcrea.ngStrap']);

angular.module('lifetracker').config(function($urlRouterProvider, $stateProvider) {
  return $stateProvider.state('lifetracker', {
    url: '/',
    views: {
      'main@': {
        templateUrl: 'templates/main.html',
        controller: 'MainController'
      },
      'nav@': {
        templateUrl: 'templates/nav.html',
        controller: 'NavController'
      },
      'sidebar@': {
        templateUrl: 'templates/sidebar.html',
        controller: 'SidebarController'
      }
    }
  });
}).factory('db', function() {
  var db, sqlite3;
  sqlite3 = require("sqlite3").verbose();
  db = new sqlite3.Database("data/database.sqlite");
  return db;
}).factory('store', function(db) {
  var store;
  store = {
    createVariable: function(data, done) {
      var statement;
      statement = db.prepare("insert into variables values ($name, $type, $min, $max, $question)");
      statement.run({
        $name: data.name,
        $question: data.question,
        $type: data.type,
        $min: data.min,
        $max: data.max
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
      return db.all("select rowid id, * from variables order by name asc", done);
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
}).controller('MainController', function($scope) {}).controller('NavController', function($scope) {
  $('.datepicker').datepicker({
    inputs: $('.range-start, .range-end')
  });
}).controller('SidebarController', function($scope, store) {
  store.getVariables(function(err, variables) {
    if (err) {
      return;
    }
    $scope.variables = variables;
    return $scope.$digest();
  });
  $scope.CreateVariablePopover = {
    visible: false
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
}).controller('CreateVariablePopoverController', function($rootScope, $scope, store) {
  $scope.variable = {
    type: 'scale'
  };
  $scope.save = function() {
    var variable;
    variable = angular.copy($scope.variable);
    return store.createVariable(variable, function(err) {
      if (err) {
        return;
      }
      $scope.CreateVariablePopover.visible = false;
      $scope.variables.push(variable);
      return $rootScope.$digest();
    });
  };
}).run(function($state) {
  return $state.go('lifetracker');
});

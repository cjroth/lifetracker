angular.module('lifetracker', ['ngSanitize', 'ngAnimate', 'ui.router', 'mgcrea.ngStrap', 'ui.bootstrap-slider', 'toggle-switch']).config(function($urlRouterProvider, $stateProvider) {
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
}).run(function($rootScope, $state, store) {
  store.getVariables(function(err, variables) {
    if (err) {
      return;
    }
    $rootScope.variables = variables;
    return $rootScope.$digest();
  });
  return $state.go('default', {
    id: 3
  });
});

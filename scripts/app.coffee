angular
  .module 'lifetracker', [
    'ngSanitize'
    'ngAnimate'
    'ui.router'
    'mgcrea.ngStrap'
    'ui.bootstrap-slider'
    'toggle-switch'
  ]
  .config ($urlRouterProvider, $stateProvider) ->

    $stateProvider

      .state 'root',
        abstract: true
        views:
          'nav@':
            templateUrl: 'templates/nav.html'
            controller: 'NavController'

      .state 'default',
        parent: 'root'
        url: '/'
        views:
          'body@':
            templateUrl: 'templates/default/default.html'
            controller: 'DefaultMainController'

      .state 'wizard',
        parent: 'root'
        url: '/wizard'
        resolve:
          variables: ($rootScope, store, $q) ->
            deferred = $q.defer()
            store.getVariables (err, variables) ->
              deferred.resolve(variables)
            return deferred.promise
        views:
          'body@':
            templateUrl: 'templates/wizard/wizard.html'
            controller: ($scope, $state, variables) ->
              $scope.records = {}
              if $state.current.name is 'wizard' then $state.go('wizard.step', id: variables[0].id)

      .state 'wizard.done',
        url: '/done'
        resolve:
          variable: -> null
        views:
          'main@body':
            templateUrl: 'templates/wizard/done.html'
            controller: 'WizardDoneController'
          'sidebar@body':
            templateUrl: 'templates/wizard/sidebar.html'
            controller: 'WizardSidebarController'

      .state 'wizard.step',
        url: '/:id'
        resolve:
          variable: ($state, $rootScope, $stateParams, variables) ->
            return _.findWhere(variables, id: ~~$stateParams.id)
        views:
          'main@body':
            templateUrl: 'templates/wizard/main.html'
            controller: 'WizardMainController'
          'sidebar@body':
            templateUrl: 'templates/wizard/sidebar.html'
            controller: 'WizardSidebarController'
  .run ($rootScope, $state, store) ->

    store.getVariables (err, variables) ->
      if err
        # @todo handle err
        return
      $rootScope.variables = variables
      $rootScope.$digest()

    $state.go('default', id: 3)
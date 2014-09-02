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
        resolve:
          variables: ($rootScope, store, $q, variableSorter) ->
            deferred = $q.defer()
            store.getVariables (err, variables) ->
              $rootScope.palette = new Rickshaw.Color.Palette(scheme: 'colorwheel')
              for variable in variables
                variable.selected = true
                variable.color = $rootScope.palette.color()
              $rootScope.variables = variables.sort(variableSorter)
              deferred.resolve(variables)
            return deferred.promise
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
          'main@body':
            templateUrl: 'templates/default/main.html'
            controller: 'DefaultMainController'
          'sidebar@body':
            templateUrl: 'templates/default/sidebar.html'
            controller: 'DefaultSidebarController'

      .state 'wizard',
        parent: 'root'
        url: '/wizard'
        views:
          'body@':
            templateUrl: 'templates/wizard/wizard.html'
            controller: ($rootScope, $scope, $state) ->
              $scope.records = {}
              if $state.current.name is 'wizard' then $state.go('wizard.step', id: $rootScope.variables[0].id)

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
  .run ($rootScope, $state, store, fixtures) ->
    fixtures()
    $state.go('default', id: 3)
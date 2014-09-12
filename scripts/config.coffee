angular
  .module('lifetracker')
  .config ($urlRouterProvider, $stateProvider, settingsProvider) ->

    settingsProvider.init()

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
        abstract: true
        parent: 'root'
        url: '/wizard'
        views:
          'body@':
            templateUrl: 'templates/wizard/wizard.html'

      .state 'wizard.done',
        url: '/:date/done'
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
        url: '/:date/:variable_id'
        resolve:
          variable: ($state, $rootScope, $stateParams) ->
            return _.findWhere($rootScope.variables, id: ~~$stateParams.variable_id)
          records: (store, $q, $stateParams) ->
            deferred = $q.defer()
            store.getRecordsForDate $stateParams.date, (err, records) ->
              if err then throw err
              deferred.resolve(records)
            return deferred.promise
          record: (records, variable, store, $q, $stateParams) ->
            record = _.findWhere(records, variable_id: variable.id)
            if not record
              record =
                variable_id: variable.id
                date: $stateParams.date
            return record
        views:
          'main@body':
            templateUrl: 'templates/wizard/main.html'
            controller: 'WizardMainController'
          'sidebar@body':
            templateUrl: 'templates/wizard/sidebar.html'
            controller: 'WizardSidebarController'

      .state 'settings',
        parent: 'root'
        url: '/settings'
        views:
          'body@':
            templateUrl: 'templates/settings/settings.html'
            controller: 'SettingsController'

  .run ($rootScope, $state, store, fixtures, variableSorter, settings, db) ->

    # fixtures()

    db.add settings.dataLocation, ->
      $state.go('default', id: 3)

    $rootScope.reloadVariables = (done) ->
      store.getVariables (err, variables) ->
        $rootScope.palette = new Rickshaw.Color.Palette(scheme: 'colorwheel')
        for variable in variables
          variable.selected = true
          variable.color = $rootScope.palette.color()
        $rootScope.variables = variables.sort(variableSorter)
        $rootScope.$digest()
        done?()
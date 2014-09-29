angular
  .module('lifetracker')
  .config ($urlRouterProvider, $stateProvider, settingsProvider) ->

    settingsProvider.init()

    $stateProvider

      .state 'root',
        abstract: true
        sticky: true
        resolve:
          variables: ($rootScope, $q, settings) ->
            deferred = $q.defer()
            $rootScope.reloadVariables ->
              deferred.resolve($rootScope.variables)
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
            controller: 'DefaultMainController'
        resolve:
          showToday: ($q, moment, db) ->
            # @todo @nedb
            # deferred = $q.defer()
            # today = moment().format('YYYY-MM-DD')
            # store.getRecordsForDate today, (err, records) ->
            #   if err then throw err
            #   deferred.resolve(records.length > 0)
            # return deferred.promise
            return true

      .state 'insights',
        parent: 'root'
        url: '/insights'
        views:
          'body@':
            templateUrl: 'templates/insights/insights.html'
            controller: 'InsightsController'
          'main@body':
            templateUrl: 'templates/insights/main.html'
          'sidebar@body':
            templateUrl: 'templates/insights/sidebar.html'

  .run ($rootScope, $state, settings, db) ->

    $rootScope.$state = $state

    $rootScope.reloadVariables = (done) ->
      db.find({}).sort(name: 1).exec (err, variables) ->
        if err then throw err
        $rootScope.palette = new Rickshaw.Color.Palette(scheme: 'colorwheel')
        for variable in variables
          variable.selected = _.contains(settings.selected, variable._id)
          variable.color = $rootScope.palette.color()
        $rootScope.variables = variables
        $rootScope.$digest()
        done?()

    $state.go('default')

    $rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
      states = []
      $state.current.name.split('.').forEach (name, i) ->
        states.push(if i then states[i - 1] + '.' + name else name)
      $rootScope.stateClasses = states.map (state) -> 'state-' + state.replace(/\./g, '-')

    return

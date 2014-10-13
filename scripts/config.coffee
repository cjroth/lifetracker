angular
  .module('lifetracker')
  .config ($urlRouterProvider, $stateProvider, settingsProvider) ->

    settingsProvider.init()

    $stateProvider

      .state 'root',
        abstract: true
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

      .state 'variables',
        parent: 'root'
        url: '/variables'
        views:
          'body@':
            templateUrl: 'templates/variables.html'
            controller: 'VariablesController'
        resolve:
          showToday: ($q, db) ->
            # @todo @nedb
            # deferred = $q.defer()
            # today = moment().format('YYYY-MM-DD')
            # store.getRecordsForDate today, (err, records) ->
            #   if err then throw err
            #   deferred.resolve(records.length > 0)
            # return deferred.promise
            return true

      .state 'correlations',
        parent: 'root'
        url: '/correlations'
        views:
          'body@':
            templateUrl: 'templates/correlations.html'
            controller: 'CorrelationsController'

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

    $state.go('variables')

    $rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
      states = []
      $state.current.name.split('.').forEach (name, i) ->
        states.push(if i then states[i - 1] + '.' + name else name)
      $rootScope.stateClasses = states.map (state) -> 'state-' + state.replace(/\./g, '-')

    # show one month ago until today as default date range
    $rootScope.end = moment()
      .subtract(settings.newDayOffsetHours, 'hours')
      .set('hour', 0)
      .set('minute', 0)
      .set('second', 0)
      .set('millisecond', 0)
    $rootScope.start = $rootScope.end.clone().subtract(settings.dateRangeSize, 'days')
    $rootScope.start.inclusive = $rootScope.start.clone().subtract(1, 'days')
    $rootScope.end.inclusive = $rootScope.end.clone().add(1, 'days')
    
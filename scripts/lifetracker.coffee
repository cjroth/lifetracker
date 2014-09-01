angular
  .module 'lifetracker', [
    'ngSanitize'
    'ngAnimate'
    'ui.router'
    'mgcrea.ngStrap'
    'ui.bootstrap-slider'
    'toggle-switch'
  ]

angular
  .module 'lifetracker'
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

  .factory 'db', ->

    sqlite3 = require("sqlite3").verbose()
    db = new sqlite3.Database("data/database.sqlite")

    db.run "CREATE TABLE if not exists variables (name TEXT, type TEXT, min FLOAT, max FLOAT, question TEXT, units TEXT, deleted_at)"
    db.run "CREATE TABLE if not exists records (variable_id INTEGER, value FLOAT, timestamp TIMESTAMP, deleted_at TIMESTAMP)" 

    return db

  .factory 'store', (db) ->

    store =

      createVariable: (data, done) ->
        statement = db.prepare("insert into variables values ($name, $type, $min, $max, $question, $units, null)")
        statement.run
          $name: data.name
          $question: data.question
          $type: data.type
          $min: data.min
          $max: data.max
          $units: data.units
        statement.finalize(done)

      deleteVariable: (id, done) ->
        statement = db.prepare("update variables set deleted_at = $deleted_at where rowid = $id")
        statement.run
          $id: id
          $deleted_at: (new Date).getTime()
        statement.finalize(done)

      updateVariable: (id, data, done) ->
        statement = db.prepare("update variables set name = $name, question = $question where rowid = $id")
        statement.run
          $id: id
          $name: data.name
          $question: data.question
        statement.finalize(done)

      createRecord: (data, done) ->
        statement = db.prepare("insert into records values ($variable_id, $value, $timestamp, null)")
        statement.run
          $variable_id: data.variable_id
          $value: data.value
          $timestamp: data.timestamp || (new Date).getTime()
        statement.finalize(done)

      getVariables: (done) ->
        db.all "select rowid id, * from variables where deleted_at is null order by name asc", (err, vars) ->
          variables = []
          for variable in vars
            variables.push variable
            done(err, variables)

      getEachVariable: (done) ->
        db.each "select rowid id, * from variables where deleted_at is null order by name asc", done

      getRecords: (done) ->
        db.all "select rowid id, * from records where deleted_at is null", done

      getEachRecord: (done) ->
        db.each "select rowid id, * from records where deleted_at is null", done

    return store

  .directive 'editVariable', ->
    link = (scope, element, attrs) ->
      $element = $(element)
      element.on 'click', ->
        
      return
    return {
      restrict: 'A'
      link: link
    }

  .run ($rootScope, store) ->

    store.getVariables (err, variables) ->
      if err
        # @todo handle err
        return
      $rootScope.variables = variables
      $rootScope.$digest()

  .controller 'NavController', ($scope, $state) ->

    $scope.$state = $state

    # initialize the datepicker
    $('.datepicker').datepicker
      inputs: $('.range-start, .range-end')

    return

  .controller 'DefaultSidebarController', ($scope, store) ->

    # ...

    return

  .controller 'DefaultMainController', ($scope, store, $window) ->

    $scope.$watch 'variables', ->

      store.getRecords (err, records) ->

        colors = ['red', 'blue', 'green']
        seriesData = {}
        series = []
        timezoneOffset = (new Date).getTimezoneOffset() * 60

        $scope.variables ?= []

        for variable in $scope.variables
          seriesData[variable.id] = []

        for record in records
          seriesData[record.variable_id]?.push(x: record.timestamp / 1000 - timezoneOffset, y: record.value)

        for variable, i in $scope.variables
          series.push
            color: colors[i]
            data: seriesData[variable.id]

        graph = new Rickshaw.Graph( {
          element: document.getElementById('chart'),
          width: $('.main').width(),
          height: $('.main').height(),
          renderer: 'line',
          series: series
        } )

        # @todo access this through dependency injection
        gui = require('nw.gui');
        win = gui.Window.get().on 'resize', ->

          graph.configure({
            width: $('.main').width(),
            height: $('.main').height(),
          });
          graph.render();

        new Rickshaw.Graph.Axis.Time({
          graph: graph
        });

        graph.render()

    return

  .controller 'WizardSidebarController', ($state, $scope, variable) ->

    $scope.goTo = (variable) ->
      $state.go('wizard.step', id: variable.id)

    $scope.currentVariable = variable

    return

  .controller 'WizardMainController', ($scope, $state, variable, variables) ->

    index = variables.indexOf(variable)
    next = variables[index + 1]
    previous = variables[index - 1]

    $scope.progress = index / variables.length * 100
    $scope.variable = variable
    $scope.record = $scope.records[variable.id] || { variable: variable }

    if variable.type is 'scale' then $scope.record.value ?= 5

    $scope.$watch 'record', ->
      $scope.records[variable.id] = $scope.record

    $scope.skip = ->
      if next
        $state.go('wizard.step', id: next.id)
      else
        $state.go('wizard.done')

    $scope.continue = ->

      if next
        $state.go('wizard.step', id: next.id)
      else
        $state.go('wizard.done')

    if previous
      $scope.previous = ->
        $state.go('wizard.step', id: previous.id)

    return

  .controller 'WizardDoneController', ($scope, $state, store, variable, variables) ->

    $scope.done = ->

      async.each _.toArray($scope.records), (record, done) ->

        data = 
          variable_id: record.variable.id
          value: if record.variable.type is 'boolean' then !!record.value else parseFloat record.value

        store.createRecord(data, done)

      , (err) ->

        $state.go('default')

    return

  .controller 'EditVariablePopoverController', ($rootScope, $scope, store) ->

    $scope.form = angular.copy($scope.variable)

    $scope.save = ->

      store.updateVariable $scope.form.id, $scope.form, (err) ->

        if err
          # @todo handle error
          return

        angular.extend($scope.variable, $scope.form)
        $scope.$hide()
        $rootScope.$digest()

  .controller 'DeleteVariablePopoverController', ($rootScope, $scope, store) ->

    $scope.delete = ->

      store.deleteVariable $scope.variable.id, (err) ->

        if err
          # @todo handle error
          return

        $rootScope.variables = _.without($rootScope.variables, $scope.variable)
        $scope.$hide()
        $rootScope.$digest()

  .controller 'CreateVariablePopoverController', ($rootScope, $scope, store) ->

    defaults = type: 'scale'
    $scope.variable = angular.copy(defaults)

    $scope.save = ->

      variable = angular.copy $scope.variable

      store.createVariable variable, (err) ->

        if err
          # @todo handle error
          return

        $scope.CreateVariablePopover.visible = false
        $scope.variables.push variable
        $rootScope.$digest()
        $scope.variable = angular.copy(defaults)

    return

  .run ($state) ->
    $state.go('default', id: 3)
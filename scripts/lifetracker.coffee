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
            controller: ($state, variables) ->
              if $state.current.name is 'wizard' then $state.go('wizard.step', id: variables[0].id)

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

    db.run "CREATE TABLE if not exists variables (name TEXT, type TEXT, min FLOAT, max FLOAT, question TEXT, units TEXT)"
    db.run "CREATE TABLE if not exists records (variable_id INTEGER, value FLOAT, timestamp INTEGER)"

    return db

  .factory 'store', (db) ->

    store =

      createVariable: (data, done) ->
        statement = db.prepare("insert into variables values ($name, $type, $min, $max, $question, $units)")
        statement.run
          $name: data.name
          $question: data.question
          $type: data.type
          $min: data.min
          $max: data.max
          $units: data.units
        statement.finalize(done)

      deleteVariable: (id, done) ->
        statement = db.prepare("delete from variables where rowid = $id")
        statement.run
          $id: id
        statement.finalize(done)

      updateVariable: (id, data, done) ->
        statement = db.prepare("update variables set name = $name, question = $question where rowid = $id")
        statement.run
          $id: id
          $name: data.name
          $question: data.question
        statement.finalize(done)

      createRecord: (record, done) ->
        statement = db.prepare("insert into records values ($variable_id, $value, $timestamp)")
        statement.run record
        statement.finalize(done)

      getVariables: (done) ->
        db.all "select rowid id, * from variables order by name asc", (err, vars) ->
          variables = []
          for variable in vars
            variables.push variable
            done(err, variables)

      getEachVariable: (done) ->
        db.each "select rowid id, * from variables order by name asc", done

      getRecords: (done) ->
        db.all "select rowid id, * from records", done

      getEachRecord: (done) ->
        db.each "select rowid id, * from records", done

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

  .controller 'NavController', ($scope) ->

    $scope.shit = {}

    # initialize the datepicker
    $('.datepicker').datepicker
      inputs: $('.range-start, .range-end')

    return

  .controller 'DefaultSidebarController', ($scope, store) ->

    # ...

    return

  .controller 'DefaultMainController', ($scope) ->
    return

  .controller 'WizardSidebarController', ($state, $scope, variable) ->

    $scope.goTo = (variable) ->
      $state.go('wizard.step', id: variable.id)

    $scope.currentVariable = variable

    return

  .controller 'WizardMainController', ($scope, variable) ->

    $scope.variable = variable
    $scope.record = {}

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
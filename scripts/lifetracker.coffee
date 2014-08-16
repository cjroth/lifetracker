angular
  .module 'lifetracker', [
    'ngSanitize'
    'ngAnimate'
    'ui.router'
    'mgcrea.ngStrap'
  ]

angular
  .module 'lifetracker'
  .config ($urlRouterProvider, $stateProvider) ->

    $stateProvider
      .state 'lifetracker',
        url: '/'
        views:
          'main@':
            templateUrl: 'templates/main.html'
            controller: 'MainController'
          'nav@':
            templateUrl: 'templates/nav.html'
            controller: 'NavController'
          'sidebar@':
            templateUrl: 'templates/sidebar.html'
            controller: 'SidebarController'

  .factory 'db', ->

    sqlite3 = require("sqlite3").verbose()
    db = new sqlite3.Database("data/database.sqlite")

    return db

  .factory 'store', (db) ->

    store =

      createVariable: (data, done) ->
        statement = db.prepare("insert into variables values ($name, $type, $min, $max, $question)")
        statement.run
          $name: data.name
          $question: data.question
          $type: data.type
          $min: data.min
          $max: data.max
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
        db.all "select rowid id, * from variables order by name asc", done

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

  .controller 'MainController', ($scope) ->
    return

  .controller 'NavController', ($scope) ->

    # initialize the datepicker
    $('.datepicker').datepicker
      inputs: $('.range-start, .range-end')

    return

  .controller 'SidebarController', ($scope, store) ->

    # initialize the selecter in the "create variable" popover
    # documentation: http://formstone.it/components/selecter
    # $('select').selecter(cover: true)

    store.getVariables (err, variables) ->
      if err
        # @todo handle err
        return
      $scope.variables = variables
      $scope.$digest()

    $scope.CreateVariablePopover =
      visible: false

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

  .controller 'CreateVariablePopoverController', ($rootScope, $scope, store) ->

    $scope.variable = type: 'scale'

    $scope.save = ->

      variable = angular.copy $scope.variable

      store.createVariable variable, (err) ->

        if err
          # @todo handle error
          return

        $scope.CreateVariablePopover.visible = false
        $scope.variables.push variable
        $rootScope.$digest()

    return

  .run ($state) ->
    $state.go('lifetracker')
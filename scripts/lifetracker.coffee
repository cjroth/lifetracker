angular
  .module 'lifetracker', [
    'ui.router'
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

  .controller 'MainController', ($scope) ->
    return

  .controller 'NavController', ($scope) ->

    # initialize the datepicker
    $('.datepicker').datepicker
      inputs: $('.range-start, .range-end')

    return

  .controller 'SidebarController', ($scope) ->

    $scope.variable =
      type: 'scale'

    # initialize the selecter in the "create variable" popover
    # documentation: http://formstone.it/components/selecter
    # $('select').selecter(cover: true)

    return

  .run ($state) ->
    $state.go('lifetracker')
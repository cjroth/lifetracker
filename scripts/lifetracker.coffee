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
    return

  .controller 'SidebarController', ($scope) ->
    return

  .run ($state) ->
    $state.go('lifetracker')
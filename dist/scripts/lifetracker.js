angular.module('lifetracker', ['ui.router']);

angular.module('lifetracker').config(function($urlRouterProvider, $stateProvider) {
  return $stateProvider.state('lifetracker', {
    url: '/',
    views: {
      'main@': {
        templateUrl: 'templates/main.html',
        controller: 'MainController'
      },
      'nav@': {
        templateUrl: 'templates/nav.html',
        controller: 'NavController'
      },
      'sidebar@': {
        templateUrl: 'templates/sidebar.html',
        controller: 'SidebarController'
      }
    }
  });
}).controller('MainController', function($scope) {}).controller('NavController', function($scope) {
  $('.datepicker').datepicker({
    inputs: $('.range-start, .range-end')
  });
}).controller('SidebarController', function($scope) {
  $scope.variable = {
    type: 'scale'
  };
}).run(function($state) {
  return $state.go('lifetracker');
});

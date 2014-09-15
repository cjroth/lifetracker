angular
  .module 'lifetracker'
  .controller 'IntroController', ($scope, $rootScope) ->

    $scope.IntroOptions = 
      steps: [
        (
          element: $('[name="create-variable-button"]')[0]
          intro: 'Start by adding a new variable.'
          position: 'right'
        )
        (
          element: $('.chart-buttons')[0]
          intro: "First tooltip"
          position: 'top-left-aligned'
        )
        (
          element: $('.nav')[0]
          intro: "First tooltip"
        )
      ]
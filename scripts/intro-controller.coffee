angular
  .module 'lifetracker'
  .controller 'IntroController', ($scope, $rootScope) ->

    $scope.IntroOptions = 
      nextLabel: 'Next',
      prevLabel: 'Back',
      doneLabel: 'Done'
      showBullets: false
      showStepNumbers: false
      steps: [
        (
          element: $('[name="create-variable-button"]')[0]
          intro: 'Start by adding a new variable.'
          position: 'right'
        )
        (
          element: $('[name="nav-record-data"]')[0]
          intro: 'Then record some data.'
          position: 'left'
        )
        # (
        #   element: $('.nav')[0]
        #   intro: "First tooltip"
        # )
      ]
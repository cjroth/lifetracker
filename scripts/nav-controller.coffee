angular
  .module 'lifetracker'
  .controller 'NavController', ($rootScope, $scope, $state, moment, settings, $previousState) ->

    $scope.importExportPopover =
      show: false
      toggle: (show) -> @show = if show? then show else not @show

angular
  .module 'lifetracker'
  .controller 'SettingsController', ($scope, settings, $rootScope, db, store) ->

    fs = require('fs')

    $scope.settings = settings

    $('[name="settings-data-location-button"]').on 'click', ->
      $('[name="settings-data-location"]').click()

    $('[name="settings-data-location"]').on 'change', ->
      $scope.settings.dataLocation = @value
      settings.dataLocation = @value
      settings.save()
      db.add settings.dataLocation, ->
        $rootScope.reloadVariables()

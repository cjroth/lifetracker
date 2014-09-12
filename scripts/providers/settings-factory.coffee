angular
  .module 'lifetracker'
  .provider 'settings', ->

    # @todo use dependency injection for these
    fs = require('fs')
    path = require('path')
    # also JSON, _

    defaultsFilePath = path.resolve('defaults.json')
    settingsFilePath = path.resolve('settings.json')

    settings = {}

    settings.setup = ->
      if fs.existsSync(settingsFilePath)
        settings.load()
      else
        json = fs.readFileSync(defaultsFilePath)
        data = JSON.parse(json)
        settings = _.defaults(settings, data)
      return settings

    settings.save = ->
      json = JSON.stringify(settings)
      fs.writeFileSync(settingsFilePath, json)

    settings.load = ->
        json = fs.readFileSync(settingsFilePath)
        data = JSON.parse(json)
        settings = _.extend(settings, data)

    return (
      init: settings.setup
      $get: -> settings
    )
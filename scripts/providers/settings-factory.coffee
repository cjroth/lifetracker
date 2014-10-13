angular
  .module 'lifetracker'
  .provider 'settings', ->

    defaults = {
      "dataLocation": "data.sqlite",
      "dateRangeSize": 7,
      "minimumRecordsThreshold": 7,
      "newDayOffsetHours": 4,
      "chart": {
        "name": "line",
        "stacked": "true"
      },
      "selected": []
    }

    settings = {}

    settings.defaults = ->
        settings = _.defaults(settings, defaults)

    settings.setup = ->
      settings.defaults()
      return settings

    settings.save = ->
      return

    settings.load = ->
      return

    return (
      init: settings.setup
      $get: -> settings
    )
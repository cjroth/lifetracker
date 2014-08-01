chokidar = require('chokidar')

chokidar
  .watch '.',
    ignoreInitial: true
    ignored: new RegExp 'node_modules|^\.git|^data'
  .on 'all', (event, path) ->
    return if path is '.'
    console.log 'Reloading app: "' + path + '" has changed.'
    location.reload?()
chokidar = require('chokidar')

chokidar
  .watch ".",
    ignoreInitial: true
    ignored: new RegExp "node_modules|^\.git"
  .on "all", (event, path) ->
    return if path is "."
    location.reload?()
    
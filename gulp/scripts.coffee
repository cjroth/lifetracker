# through = require('through')
# File = require('vinyl')
gulp  = require('gulp')
$     = require('gulp-load-plugins')()
# paths = require('./paths')
# handleErrors = require('./handle-errors')

# buildScriptList = ->

#   files = []
#   filePaths = []

#   onFile = (file) ->
#     files.push file
#     filePaths.push file.path

#   onEnd = ->

#     file = new File(
#       path: 'scripts.list.json',
#       contents: new Buffer(JSON.stringify(filePaths, null, '  '))
#     )

#     @emit 'data', file

#     @emit 'end'

#   through onFile, onEnd

# gulp.task 'clean:scripts', ->
#   gulp
#     .src [
#       paths.devFolder + '/js/*'
#       '!' + paths.devFolder + '/js/*.js'
#       '!' + paths.devFolder + '/js/config/'
#     ]
#     .pipe handleErrors(title: 'gulp clean:scripts')
#     .pipe $.clean(read: false)

# gulp.task 'build:scripts:files', ['clean:scripts', 'build:vendor', 'build:templates', 'build:config'], ->
#   gulp
#     .src 'client/src/**/*.coffee'
#     .pipe handleErrors(title: 'gulp build:scripts')
#     .pipe $.coffee(bare: true)
#     .pipe gulp.dest(paths.devFolder + '/js/')

paths =
  scripts: 'scripts/**/*.coffee'
  templates: 'views/**/*.jade'
  index: 'index.jade'

gulp.task 'build:scripts', ->
  gulp
    .src paths.scripts
    .pipe $.coffee(bare: true)
    # .pipe $.angularFilesort()
    .pipe gulp.dest('dist/scripts')

gulp.task 'build:templates', ->
  gulp
    .src paths.templates
    .pipe $.jade(pretty: true)
    .pipe gulp.dest('dist/templates')

gulp.task 'build:index', ->
  gulp
    .src paths.index
    .pipe $.jade(pretty: true)
    .pipe gulp.dest('dist')

gulp.task 'build:watch', ->
  gulp
    .watch [
      paths.scripts
      paths.templates
      paths.index
    ], ['build']

gulp.task 'build', ['build:scripts', 'build:templates', 'build:index']

gulp  = require('gulp')
$     = require('gulp-load-plugins')()

paths =
  scripts: 'scripts/**/*.coffee'
  templates: 'views/**/*.jade'
  index: 'index.jade'

gulp.task 'build:scripts', ->
  gulp
    .src paths.scripts
    .pipe $.coffee(bare: true)
    .pipe gulp.dest('dist/scripts')

gulp.task 'build:templates', ->
  gulp
    .src paths.templates
    .pipe $.jade(pretty: true)
    .pipe gulp.dest('dist/templates')

gulp.task 'build:index', ['build:scripts'], ->
  gulp
    .src paths.index
    .pipe $.jade(pretty: true)
    .pipe($.inject(
      gulp
        .src(['./dist/scripts/**/*.js'])
        .pipe($.angularFilesort())
      , relative: true, ignorePath: '/dist'
    ))
    .pipe gulp.dest('dist')

gulp.task 'build:watch', ['build'], ->
  gulp
    .watch [
      paths.scripts
      paths.templates
      paths.index
    ], ['build']

gulp.task 'build', ['build:templates', 'build:index']

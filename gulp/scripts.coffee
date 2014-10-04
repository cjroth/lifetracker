path  = require('path')
gulp  = require('gulp')
$     = require('gulp-load-plugins')()

paths =
  scripts: 'scripts/**/*.coffee'
  templates: 'views/**/*.jade'
  stylesheets: 'styles.less'
  index: 'index.jade'
  website: 'website/index.jade'
  bower: 'bower_components'
  node: 'node_modules'

gulp.task 'build:dependencies', [
  'build:dependencies:node'
  'build:dependencies:bower'
]

gulp.task 'build:dependencies:bower', ->
  gulp.src path.join(paths.bower, '**/*')
  .pipe gulp.dest 'dist/bower_components'

gulp.task 'build:dependencies:node', ->
  gulp.src path.join(paths.node, '**/*')
  .pipe gulp.dest 'dist/node_modules'

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

gulp.task 'build:website', ->
  gulp
    .src paths.website
    .pipe $.jade(pretty: true)
    .pipe gulp.dest('website')

gulp.task 'build:stylesheets', ->
  gulp
    .src paths.stylesheets
    .pipe $.less()
    .pipe gulp.dest('dist/stylesheets')

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
      paths.stylesheets
      paths.index
      paths.website
    ], ['build']

gulp.task 'build', ['build:stylesheets', 'build:templates', 'build:index', 'build:website', 'build:dependencies']

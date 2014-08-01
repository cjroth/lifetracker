gui = require("nw.gui");
sqlite3 = require("sqlite3").verbose()
db = new sqlite3.Database("data/database.sqlite")
jade = require("jade")
fs = require("fs")
qs = require('querystring')

createVariable = (data, done) ->
  statement = db.prepare("insert into variables values ($name, $type, $min, $max, $question)")
  statement.run
    $name: data.name
    $question: data.question
    $type: data.type
    $min: data.min
    $max: data.max
  statement.finalize(done)

deleteVariable = (id, done) ->
  statement = db.prepare("delete from variables where rowid = $id")
  statement.run
    $id: id
  statement.finalize(done)

updateVariable = (id, data, done) ->
  statement = db.prepare("update variables set name = $name, question = $question where rowid = $id")
  statement.run
    $id: id
    $name: data.name
    $question: data.question
  statement.finalize(done)

createRecord = (record, done) ->
  statement = db.prepare("insert into records values ($variable_id, $value, $timestamp)")
  statement.run record
  statement.finalize(done)

getVariables = (done) ->
  db.all "select rowid id, * from variables order by name asc", done

getEachVariable = (done) ->
  db.each "select rowid id, * from variables order by name asc", done

getRecords = (done) ->
  db.all "select rowid id, * from records", done

getEachRecord = (done) ->
  db.each "select rowid id, * from records", done

loadSidebar = ->
  getVariables (err, variables) ->
    $sidebar = $('.sidebar');
    $sidebar.html jade.renderFile "views/sidebar.jade", variables: variables
    bindEvents($sidebar)

launchModal = (modalName, options) ->
  html = jade.renderFile('views/modals/' + modalName + '.jade', options)
  $modal = $(html)
  $modal.appendTo($('body'))
  $modal.modal('show')
  $modal.on 'hidden.bs.modal', ->
    $modal.remove()
  bindEvents($modal)

db.serialize ->

  db.run "CREATE TABLE if not exists variables (name TEXT, type TEXT, min FLOAT, max FLOAT, question TEXT)"
  db.run "CREATE TABLE if not exists records (variable_id INTEGER, value FLOAT, timestamp INTEGER)"

  # createVariable
  #   $name: "Sleep"
  #   $type: "boolean"

  # createRecord
  #   $variable_id: 1
  #   $value: 8.5
  #   $timestamp: new Date().getTime()

  # getEachVariable (err, variable) ->
  #   console.log 'var', arguments

  # getEachRecord (err, record) ->
  #   console.log 'record', arguments

  loadSidebar()

bindEvents = ($element) ->

  # documentation: http://bootstrap-datepicker.readthedocs.org/en/release/index.html
  $element.find('.datepicker').datepicker()

  # documentation: http://formstone.it/components/selecter
  $element.find('select').selecter(cover: true)

  $element.find('[data-toggle="popover"]').popover()

  $element.find('[data-dismiss="popover"]').on 'click', ->
    id = $(@).parents('.popover').attr('id')
    $trigger = $('[aria-describedby="' + id + '"]')
    $trigger.popover('hide')

  $element.find('[data-launch-modal]').on 'click', (event) ->
    event.stopPropagation()
    modalName = $(this).data('launch-modal')
    data = $(this).data('modal-locals')
    launchModal(modalName, data)

  $element.find('form[name="variable"]').on 'submit', (event) ->
    $form = $ @
    data = $(this).serialize()
    data = qs.parse(data)
    # @todo validate here...
    createVariable data, (err) ->
      if err
        # @todo handle error...
        return
      $form.parents('.modal').modal('hide')
      loadSidebar()
    return false

  $element.find('form[name="variable-delete"]').on 'submit', (event) ->
    $form = $ @
    data = $form.serialize()
    data = qs.parse(data)
    # @todo validate here...
    deleteVariable data.id, (err) ->
      if err
        # @todo handle error...
        return
      $form.parents('.modal').modal('hide')
      loadSidebar()
    return false

  $element.find('form[name="variable-edit"]').on 'submit', (event) ->
    $form = $ @
    data = $form.serialize()
    data = qs.parse(data)
    # @todo validate here...
    updateVariable data.id, data, (err) ->
      if err
        # @todo handle error...
        return
      $form.parents('.modal').modal('hide')
      loadSidebar()
    return false

  $element.find('.variable-toggle').each (i) ->
    $e = $ @
    $e.popover
      trigger: 'manual'
      content: jade.renderFile('views/test-form.jade', $e.data('model'))
      html: true
    $e.on 'click', ->
      $e.toggleClass('active')
      return false
    $e.find '[href="#edit-variable"]'
      .on 'click', ->
        $e.popover('toggle')
        $popover = $('#' + $e.attr('aria-describedby'))
        bindEvents($popover)
        return false

$('body').html jade.renderFile('views/app.jade')

bindEvents $('body')

# db.close()

gui = require("nw.gui");
sqlite3 = require("sqlite3").verbose()
db = new sqlite3.Database("data/database.sqlite")
jade = require("jade")
fs = require("fs")
qs = require('querystring')

createVariable = (data, done) ->
  statement = db.prepare("INSERT INTO variables VALUES ($name, $type, $min, $max, $question)")
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
  statement = db.prepare("INSERT INTO records VALUES ($variable_id, $value, $timestamp)")
  statement.run record
  statement.finalize(done)

getVariables = (done) ->
  db.all "SELECT rowid id, * FROM variables", done

getEachVariable = (done) ->
  db.each "SELECT rowid id, * FROM variables", done

getRecords = (done) ->
  db.all "SELECT rowid id, * FROM records", done

getEachRecord = (done) ->
  db.each "SELECT rowid id, * FROM records", done

loadSidebar = ->
  getVariables (err, variables) ->
    $sidebar = $('.sidebar');
    $sidebar.html jade.renderFile("views/sidebar.jade", variables: variables)
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

  $element.find("select").selecter cover: true

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

  $element.find('.variable-toggle').on 'click', (event) ->
    console.log 'clicked'
    $(this).toggleClass('active')
    return false

$('body').html jade.renderFile('views/app.jade')

bindEvents $('body')

# db.close()

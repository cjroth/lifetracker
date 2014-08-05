gui = require("nw.gui");
sqlite3 = require("sqlite3").verbose()
db = new sqlite3.Database("data/database.sqlite")
jade = require("jade")
fs = require("fs")
qs = require('querystring')

# tray = new gui.Tray({ icon: 'icon-really-big.png' });

# menu = new gui.Menu();
# menu.append(new gui.MenuItem({ type: 'checkbox', label: 'Add note' }));
# tray.menu = menu;

win = gui.Window.get();
nativeMenuBar = new gui.Menu({ type: "menubar" });
nativeMenuBar.createMacBuiltin("My App");
win.menu = nativeMenuBar;

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

loadSidebarVariables = ->
  getVariables (err, variables) ->
    $sidebarVariables = $('.sidebar-variables');
    $sidebarVariables.html jade.renderFile "views/sidebar-variables.jade", variables: variables
    bindEvents($sidebarVariables)

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

  loadSidebarVariables()

destroyAllPopovers = (element) ->
  $element = $ element
  $element.find('.popover').each (i) ->
    $popover = $(@)
    id = $popover.attr('id')
    $trigger = $('[aria-describedby="' + id + '"]')
    $trigger.popover('destroy')

    # hide any popovers that were not created with the `.popover()` method
    $element.find('.popover').hide()

bindEvents = ($element) ->

  # documentation: http://formstone.it/components/selecter
  $element.find('select').selecter(cover: true)

  $element.find('[data-toggle="popover"]').popover()

  $element.find('[data-dismiss="popover"]').on 'click', ->
    $popover = $(@).parents('.popover')
    id = $popover.attr('id')
    $trigger = $('[aria-describedby="' + id + '"]')
    $trigger.popover('destroy')
    $popover.hide()

  $element.find('[data-launch-modal]').on 'click', (event) ->
    event.stopPropagation()
    modalName = $(this).data('launch-modal')
    data = $(this).data('modal-locals')
    launchModal(modalName, data)

  $element.find('form[name="create-variable"]').on 'submit', (event) ->

    $form = $ @
    data = $(this).serialize()
    data = qs.parse(data)

    # @todo validate here...

    createVariable data, (err) ->

      if err
        # @todo handle error...
        return

      $form.parents('.popover').hide()
      loadSidebarVariables()

      $container = $('.popover-create-variable-container')
      html = jade.renderFile('views/create-variable-popover.jade')
      $container.html(html)
      bindEvents($container)

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

      # hide the popover...
      id = $form.parents('.popover').attr('id')
      $trigger = $('[aria-describedby="' + id + '"]')

      loadSidebarVariables()
      destroyAllPopovers('.sidebar')

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

      loadSidebarVariables()
      destroyAllPopovers('.sidebar')

    return false

  $element.find('.variable-toggle').each (i) ->

    $e = $ @

    $e.on 'click', ->
      $e.toggleClass('active')
      return false

    $e.find '[href="#delete-variable"]'
      .on 'click', ->
        destroyAllPopovers('.sidebar')
        $e.popover
          trigger: 'manual'
          container: '.sidebar'
          content: jade.renderFile('views/delete-variable-popover.jade', $e.data('model'))
          html: true
          animation: false
        $e.popover('show')
        $popover = $('#' + $e.attr('aria-describedby'))
        bindEvents($popover)
        return false

    $e.find '[href="#edit-variable"]'
      .on 'click', ->
        destroyAllPopovers('.sidebar')
        $e.popover
          trigger: 'manual'
          container: '.sidebar'
          content: jade.renderFile('views/edit-variable-popover.jade', $e.data('model'))
          html: true
          animation: false
        $e.popover('show')
        $popover = $('#' + $e.attr('aria-describedby'))
        bindEvents($popover)
        return false

  $element.find('[href="#toggle-datepicker"]').each (i) ->

    $e = $(@)

    # documentation: http://bootstrap-datepicker.readthedocs.org/en/release/index.html
    $element.find('.datepicker').datepicker(
      inputs: $('.range-start, .range-end')
    )

    $e.on 'click', ->
      $('.popover-datepicker').toggle()

  $element.find('[href="#create-variable"]').each (i) ->

    $e = $(@)

    $e.on 'click', ->
      destroyAllPopovers('.sidebar')
      $('.popover-create-variable').toggle()
      return false

$('body').html jade.renderFile('views/app.jade')

bindEvents $('body')

# db.close()

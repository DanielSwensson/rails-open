{CompositeDisposable} = require 'atom'

module.exports = RailsOpen =
  subscriptions: null

  activate: ->

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'rails-open:open-index': => @openIndex()

  deactivate: ->
    @subscriptions.dispose()

  openIndex: ->
    if editor = atom.workspace.getActiveTextEditor()
      getControllerName editor
      .then (controllerName) ->
        if uri = getURI controllerName
          open(uri)
      .catch (err) ->
        atom.notifications.addError(err.reason)

getURI = (controllerName) ->
  try
    exec = require("child_process").execSync
    cmd = "CONTROLLER=#{controllerName} bundle exec rake routes | grep '#index'"
    routes = exec(
      cmd,
      cwd: atom.project.getPaths()[0],
      encoding: 'utf8'
    )
    routes.trim().split(/\s+/)[2].replace('(.:format)', '')
  catch err
    atom.notifications.addError("Cant find route for #{controllerName}")
    null

open = (path) ->
  opn = require 'opn'
  opn 'http://localhost:3000/' + path

getControllerName = (editor) ->
  return new Promise (resolve, reject) ->
    fullPath = editor.getPath()
    [_,relativePath] = atom.project.relativizePath(fullPath)
    if relativePath.startsWith 'app/controllers/'
      resolve relativePath.replace('app/controllers/', '').replace('_controller.rb', '')
    else
      reject reason: "#{relativePath} is not a rails controller"

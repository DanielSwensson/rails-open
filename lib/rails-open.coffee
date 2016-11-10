{CompositeDisposable} = require 'atom'

Routes = require './routes'

routes = new Routes()

module.exports = RailsOpen =
  subscriptions: null

  config:
    URL:
      title: 'Target URL'
      description: 'Opens the URL in default browser'
      type: 'string'
      default: 'http://localhost:3000'

  activate: ->

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'rails-open:open-index': => @openIndex()

  deactivate: ->
    @subscriptions.dispose()

  openIndex: ->
    if editor = atom.workspace.getActiveTextEditor()
      if controllerName = getControllerName editor
        routes.getUri controllerName
        .then (uri) ->
          open "/#{uri}"
        .catch (err) ->
          atom.notifications.addError(err.reason)

# --- end of module ---
open = (path) ->
  opn = require 'opn'
  opn atom.config.get('rails-open.URL') + path

getControllerName = (editor) ->
    fullPath = editor.getPath()
    if project = atom.project
      [_,relativePath] = project.relativizePath(fullPath)
      if !relativePath.startsWith 'app/controllers/'
        atom.notifications.addError("#{relativePath} is not a rails controller")
        return
      relativePath.replace('app/controllers/', '').replace('_controller.rb', '')
    else
      atom.notifications.addError("Can't find atom project")

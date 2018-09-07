{CompositeDisposable, File} = require 'atom'
subs = new CompositeDisposable
{readFileSync, writeFileSync} = require 'fs'
{resolve, dirname, join} = require 'path'
{parse, stringify} = JSON
{keys, assign} = Object
match = require 'minimatch'

{read, write} = require './read-write'
{filter, uid} = require './filter'
{name} = require '../package.json'
#backup = 'sync-settings.extraFiles'

{exec} = require 'child_process' # TODO

# Snippets
recursive = '**/*.[cj]son'
global = "#{atom.configDirPath}/snippets"
local = ["?(.)snippets{.cson,/#{recursive}}",'package.json']
# TODO add support for module.exports.snippets? #?(.)snippets{.@(cson|js|coffee),}

#-------------------------------------------------------------------------------
activate = =>
  {glob, sync} = require './glob'

  files = ["#{global}/#{recursive}"].concat local
  #files.push '?(.)@(project|atom).cson' TODO from project-config API

  paths = []
  glob files
    #.map watch
    .map (path) ->
      watch path
      paths.push path
      read path
    .map (snippets, i) -> load snippets, paths[i]
  write @snippets

  # TODO break Gist sync into sync-snippets-gists package?
  #if atom.config.get "#{name}.gist" #settings().gist #sync
    #

  # Backup snippets with sync-settings if installed
  #if packages.isPackageLoaded 'sync-settings'
    #atom.config.pushAtKeyPath 'sync-settings.syncSnippets', false
    #unless pattern in atom.config.get backup
      #atom.config.pushAtKeyPath backup, pattern

#-------------------------------------------------------------------------------

  # Automatically load newly created snippets.
  subs.add atom.workspace.observeTextEditors (editor) ->
    editor.onDidSave ({path}) ->
      watch path if files.some (snippets) ->

        exec "echo '#{snippets}\n' >> ~/Desktop/test"
        match path, snippets, {dot: true, matchBase: true}

  # Override Snippets… menu.
  subs.add atom.commands.add 'atom-workspace',
    "#{name}:open", -> open sync global+'{,.cson}'
  #atom.commands.remove application:open-your-snippets TODO

open = (snippets) -> # folder
  atom.open pathsToOpen: snippets

#-------------------------------------------------------------------------------

#provide = -> # API TODO
  #load: (snippets) =>
    #load read snippets

watch = (file) => # Automatically reload modified snippets.

  #exec "say watching #{file}"

  {path} = file = new File file
  subs.add file.onDidDelete -> unload path; file.dispose()
  subs.add file.onDidRename -> unload path
  subs.add file.onDidChange =>
    snippets = read path
    load snippets, path
    write @snippets

  #folder = new Folder item
  #subs.add folder.onDidChange -> glob path.join folder, recursive

load = (snippets, path) =>
  {filter} = require './filter' #valid

  # Prevent Atom from caching this.
  if path.endsWith 'package.json'
    delete require.cache[require.resolve path]

  # Merge snippets across multiple files into a single valid JSON {object}.
  keys(snippets).map (scope) =>
    @snippets ?= {} #keys(snippets[scope]).filter(valid).map (title) =>
    for title, snippet of snippets[scope]
      try
        snippet = filter path, title, snippet

        # If we're using multiple prefixes
        if snippet[path + ":" + title]['prefix'] instanceof Array
          for prefix, index in snippet[path + ":" + title]['prefix']

            new_key = path + ":" + title + ":" + index

            sub_snippet = {}
            sub_snippet[new_key] = JSON.parse(JSON.stringify(snippet[path + ":" + title]))
            sub_snippet[new_key]['prefix'] = prefix

            @snippets[scope] = assign @snippets[scope] ? {}, sub_snippet
        else
          @snippets[scope] = assign @snippets[scope] ? {}, snippet
      catch err
        error err, path
  #return @snippets

# Remove snippets associated with file.
unload = (file) =>
  keys(@snippets).map (scope) =>
    keys(@snippets[scope]).map (snippet) ->
      remove snippet if ~snippet.indexOf file
  write @snippets

remove = (snippet) =>
  keys(@snippets).find (scope) =>
    delete @snippets[scope][snippet]

#-------------------------------------------------------------------------------

error = (err, path) => #{stack})
  atom.notifications.addError name,
    #icon: 'bug' #plug #alert
    detail: err #description # Markdown
    stack: err.stack ? path #:0:0
    dismissable: true
    #buttons: [
      #text: "Edit Snippets"
      #onDidClick: -> atom.open path #:0:0 #newWindow: false
    #]

deactivate = -> subs.dispose()
#-------------------------------------------------------------------------------
module.exports = {activate, deactivate, recursive}

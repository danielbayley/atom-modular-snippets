{readFileSync} = require 'fs'
{dirname} = require 'path'
{parse, stringify} = JSON
{name} = require '../package.json'

regex = '\\$({([^:]+?)}|(\\w+))' #(?!\\d:)

#-------------------------------------------------------------------------------

# Process each snippet
filter = (path, title, snippet) =>
  return unless valid snippet, title

  if snippet.file? # Read in snippet.body from file:'path'.
    snippet.body = readFileSync "#{dirname path}/#{snippet.file}",'utf8'
    delete snippet.file

  else if atom.config.get "#{name}.variables"
    snippet.body = evaluate snippet

  # Ensure snippet has a unique ID to avoid overriding others,
  snippet.rightLabelHTML ?= title # but preserve name for autocomplete.
  id = uid path, title
  return "#{id}": snippet #[id]:

#-------------------------------------------------------------------------------

valid = (snippet, name) -> #unless typeof snippet is 'object'
  {prefix, body, file} = parse stringify snippet
  if prefix? and (body? or file?)
    return true
  else ['prefix','body'].find (key) -> unless snippet[key]?
    throw "Snippet '#{name}' is missing #{key}."

evaluate = ({body}) -> #allowUnsafeEval
  {Function} = require 'loophole'

  vars = body.match ///#{regex}///g
  vars?.map (variable) ->
    match = variable.match regex
    content = match[2] ? match[3]
    value =
      if variable[1] is '{'
        new Function("return #{content}")()
      else process.env[content]

    body = body.replace variable, value
  return body

# Ensure snippet has a unique ID to avoid overriding others.
uid = (path, name) -> #Math.random().toString(16).substr 2,4
  #path = atom.project?.relativizePath(path)[1]
    #.replace atom.configDirPath,"ATOM_HOME"
    #.replace process.env.HOME,"~"
  return "#{path}:#{name}"

#-------------------------------------------------------------------------------
module.exports = {filter, valid, evaluate, uid}

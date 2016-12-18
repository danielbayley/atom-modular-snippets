{writeFileSync} = require 'fs'
#require 'require-cson'
{error} = require './index'
{name} = require '../package.json'

success = "#{name}: Compiled snippets are available."

#-------------------------------------------------------------------------------

valid = (source) -> /^\.(source|text)|^\*$/.test source

read = (file) ->
  require 'require-cson'
  try #cson-parser
    {snippets} = raw = require file
    if snippets? or Object.keys(raw).some valid
      snippets ?= raw
    else {}
  catch err
    error err, file

write = (snippets) ->
  writeFileSync "#{atom.configDirPath}/snippets.json", JSON.stringify snippets
  if atom.config.get "#{name}.notify"
    # FIXME https://github.com/atom/node-pathwatcher/issues/74
    atom.notifications.addSuccess success, dismissable: true

#-------------------------------------------------------------------------------
module.exports = {read, write}

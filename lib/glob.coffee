{statSync} = require 'fs'
{join} = require 'path'
{sync} = require 'glob-all'
{recursive} = require './index'

options =
  cwd: atom.project?.getPaths()[0] #? process.cwd()
  dot: true
  #matchBase: true
  realpath: true #absolute
  #nodir: true
  follow: true # symlinks
  #stat: true #mark
  #cache: TODO

#-------------------------------------------------------------------------------

flatten = (paths, i) ->
  if Array.isArray i
    return i.reduce flatten, paths
  paths.push i
  return paths

recurse = (path) ->
  #folder = /(^|[/])\.?[^.]+$/
  #if folder.test path

  if statSync(path).isDirectory()
    glob join path, recursive
  else return path

glob = (snippets) ->
  sync snippets, options
    .map recurse
    .reduce flatten, []

  ###
  {globs} = glob snippets, options, =>
    globs?.map ({cache, found}) =>
      found?.map (path) =>

        if cache?[path] is 'DIR'
          path = join path, recursive
          glob path, callback
        else callback path
  ###

#-------------------------------------------------------------------------------
module.exports = {glob, sync}#, recurse, flatten}
#unless process.env.NODE_ENV is 'production' TODO
  #{recurse, flatten}

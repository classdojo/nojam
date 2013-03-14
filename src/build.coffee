
amdify = require "amdify"
at     = amdify.transformers
async  = require "async"
stepc  = require "stepc"
outcome = require "outcome"
fs = require "fs"
path = require "path"
dref = require "dref"

module.exports = class
  
  ###
  ###

  constructor: (ops, packageManagers) ->
    @_jam = packageManagers.packageManagers.jam
    @_directory = process.cwd()
    @_prefix =  (dref.get(ops.pkg, "jam.packageDir") or "jam");
    @_output = @_directory + "/" + @_prefix


  ###
  ###

  run: (callback) ->

    o = outcome.e callback
    dir = @_directory + "/node_modules"
    output = @_output
    self = @


    stepc.async(
      (() ->
        fs.readdir dir, @
      ),
      (o.s (dirs) ->
        this null, self._fixDirs(dir, dirs)
      ),
      (o.s (dirs) ->
        self._amdifyAll dirs, this
      ),
      (o.s () ->
        self._jam.rebuild @
      ),
      callback
    )

  ###
  ###

  _fixDirs: (base, dirs) ->
    dirs.map((d) ->
      base + "/" + d
    ).filter (d) ->
      path.basename(d).substr(0,1) isnt "." and fs.lstatSync(d).isDirectory()


  ###
  ###

  _amdifyAll: (dirs, callback) ->
    async.map dirs, ((dir, callback) =>
      @_amdify dir, (err) ->
        callback()
    ), callback


  




  ###
  ###

  _amdify: (dir, callback) ->


    amdify {
      entry: require.resolve(dir),
      directory: @_directory,
      prefix: @_prefix
    }, outcome.e(callback).s (bundle) =>


      transformer = new at.Template("amd")
      transformer = new at.Copy({ output: @_directory }, transformer)

      bundle.transform(transformer, callback)

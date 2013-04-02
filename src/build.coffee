
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

  constructor: (@ops, packageManagers) ->
    
    @_jam = packageManagers.packageManagers.jam
    @_directory = process.cwd()
    @_prefix =  (dref.get(ops.pkg, "jam.packageDir") or "jam");

    baseDir = dref.get(ops.pkg, "jam.baseUrl") or ""


    @_output = @_directory + "/" + @_prefix
    @_prefix = @_prefix.replace(new RegExp("^#{baseDir}"), "")
    @_baseDir = @_directory + "/" + baseDir
    

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
        this.dirs = dirs
        self._amdifyAll dirs, this
      ),
      (o.s () ->
        self._fixPackage this.dirs, this
      ),
      (o.s () ->
        self._jam.rebuild @
      ),
      callback
    )

  ###
  ###

  _fixPackage: (dirs, next) ->
    return next()

    d = {}

    dirs.map (dir) =>
      bn = path.basename(dir)
      d[bn] = path.join(@_prefix, bn, require.resolve(dir).replace(dir, "").replace(".js", ""))


    dref.set @ops.pkg, "jam.config.paths", d

    pkgPath = path.join(@ops.dir, "package.json")

    fs.writeFile pkgPath, JSON.stringify(@ops.pkg, null, 2), next


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
      prefix: ""
    }, outcome.e(callback).s (bundle) =>

      #console.log @_output, @_prefix

      transformer = new at.Template("amd")
      transformer = new at.Copy({ output: @_output }, transformer)

      bundle.transform(transformer, callback)

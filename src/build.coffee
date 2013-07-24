
amdify = require "amdify"
at     = amdify.transformers
async  = require "async"
stepc  = require "stepc"
outcome = require "outcome"
fs = require "fs"
path = require "path"
dref = require "dref"
spawn = require("child_process").spawn
glob = require "glob"

module.exports = class
  
  ###
  ###

  constructor: (@ops, packageManagers) ->
    
    @_jam = packageManagers.packageManagers.jam
    @_directory = process.cwd()
    @_ignore = ops.nojam?.ignore or []
    @_prefix =  (dref.get(ops.pkg, "jam.packageDir") or "jam");

    baseDir = dref.get(ops.pkg, "jam.baseUrl") or ""


    @_output = @_directory + "/" + @_prefix
    @_prefix = @_prefix.replace(new RegExp("^#{baseDir}"), "")
    @_baseDir = @_directory + "/" + baseDir
    @_usedDeps = glob.sync("**", { cwd: @_output })

    

  ###
  ###

  run: (callback) ->

    @_rebuildDir @_directory, () => 
      @_buildJamDeps () => 
        @_jam.rebuild callback


  ###
  ###

  _buildJamDeps: (callback) ->
    self = @
    stepc.async(
      (() ->
        fs.readdir self._output, @
      ),
      ((err, dirs = []) ->
        self._fixPackages dirs
        async.eachSeries dirs, ((dir, next) ->
          console.log "install %s", dir
          return if self._checkIgnore(dir, next)
          return next() if dir is ".DS_Store"
          return next() unless fs.lstatSync(self._output + "/" + dir).isDirectory()
          self._rebuildDir self._output + "/" + dir, next
        ), @
      ),
      callback
    )

  ###
  ###

  _rebuildDir: (dir, callback) ->

    return if @_checkIgnore(dir, callback)

    fdir = dir
    pkgPath = fdir + "/package.json"
    nodeModulesDir = fdir + "/node_modules"
    return callback() unless fs.existsSync(pkgPath)
    pkg = require pkgPath
    deps = Object.keys pkg.nojam?.dependencies ? pkg.dependencies ? {}
    @_ignore = (pkg.nojam?.ignore or []).concat @_ignore or []


    return callback() unless deps.length
    self = @
    #deps = deps.filter (dep) ->
    #  not fs.existsSync(self._output + "/" + dep)

    stepc.async(
      (() ->
        spawn("npm", ["install"], { cwd: fdir }).once("close", () =>
          @()
        )
      ),
      (() ->
        fs.readdir nodeModulesDir, @
      ),
      ((err, dirs = []) ->

        dirs = dirs.filter (dir) ->
          ~deps.indexOf(dir) and not fs.existsSync(self._output + "/" + dir)

        async.eachSeries dirs, ((dir, next) ->
          return next() if /\.bin|\.DS_Store/.test dir
          fp = nodeModulesDir + "/" + dir
          console.log "install %s", dir
          return if self._checkIgnore(dir, next)
          self._amdify fp, () -> 
            next()
        ), @
      ),
      callback
    )


  ###
  ###

  _fixPackages: (dirs) ->

    for name in dirs
      dir = @_output + "/" + name 
      pkgPath = dir + "/package.json"
      continue unless fs.lstatSync(dir).isDirectory()
      unless fs.existsSync pkgPath
        console.log "writing package %s", pkgPath
        fs.writeFileSync pkgPath, JSON.stringify({ name: name, description: name }, null, 2), "utf8"


  ###
  ###

  _checkIgnore: (dir, next) ->

    if ~@_ignore.indexOf dir
      console.log "skip %s", dir
      next()
      return true

    return false


  ###
  ###

  _fixDirs: (base, dirs) ->
    dirs.map((d) ->
      pt = base + "/" + d
      while (stat = fs.lstatSync(pt)).isSymbolicLink()
        pt = fs.readlinkSync pt
      pt
    ).filter (d) ->
      path.basename(d).substr(0,1) isnt "." and fs.lstatSync(d).isDirectory()


  ###
  ###

  _amdify: (dir, callback) ->

    return if @_checkIgnore(dir, callback)

    amdify {
      entry: require.resolve(dir),
      prefix: ""
    }, outcome.e(callback).s (bundle) =>

      transformer = new at.Template("amd")
      transformer = new at.Copy({ output: @_output }, transformer)

      transformer.filter (dep) =>
        if ~@_usedDeps.indexOf(dep.alias) then false else (@_usedDeps.push(dep.alias))

      bundle.transform(transformer, callback)

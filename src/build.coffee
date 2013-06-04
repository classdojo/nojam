
amdify = require "amdify"
at     = amdify.transformers
async  = require "async"
stepc  = require "stepc"
outcome = require "outcome"
fs = require "fs"
path = require "path"
dref = require "dref"
spawn = require("child_process").spawn

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
    @_usedDeps = fs.readdirSync(@_output).map (dir) =>  
      try 
        require.resolve(@_output + "/" + dir).replace(@_output + "/", "")
      catch e
        undefined

    

  ###
  ###

  run: (callback) ->

    @_rebuildDir @_directory, () => @_buildJamDeps () => @_jam.rebuild callback


  ###
  ###

  _buildJamDeps: (callback) ->
    self = @
    stepc.async(
      (() ->
        fs.readdir self._output, @
      ),
      ((err, dirs = []) ->
        async.eachSeries dirs, ((dir, next) ->
          console.log "install %s", dir
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

    fdir = dir
    pkgPath = fdir + "/package.json"
    nodeModulesDir = fdir + "/node_modules"
    pkg = require pkgPath
    deps = Object.keys pkg.nojam?.dependencies ? pkg.dependencies ? {}


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
          self._amdify fp, () -> 
            next()
        ), @
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
      pt = base + "/" + d
      while (stat = fs.lstatSync(pt)).isSymbolicLink()
        pt = fs.readlinkSync pt
      pt
    ).filter (d) ->
      path.basename(d).substr(0,1) isnt "." and fs.lstatSync(d).isDirectory()


  ###
  ###

  _amdify: (dir, callback) ->


    amdify {
      entry: require.resolve(dir),
      prefix: ""
    }, outcome.e(callback).s (bundle) =>

      transformer = new at.Template("amd")
      transformer = new at.Copy({ output: @_output }, transformer)

      transformer.filter (dep) =>
        if ~@_usedDeps.indexOf(dep.alias) then false else (@_usedDeps.push(dep.alias))

      bundle.transform(transformer, callback)

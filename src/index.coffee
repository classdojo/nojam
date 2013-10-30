step    = require "step"
amdify  = require "amdify"
at      = amdify.transformers
async   = require "async"
outcome = require "outcome"
resolve = require "resolve"
_       = require "underscore"

class NoJam

  ###
  ###

  constructor: (@options) ->

  ###
  ###

  rebuild: (next = () ->) ->
    @_parseConfig()
    o = outcome.e next

    self = @

    step(

      # scan the dependencies
      (() ->
        self._scanDeps @
      ), 

      # copy the bundles
      o.s((bundles) ->
        self._copyBundles bundles, next
      ),

      #
      next
    )


  ###
  ###

  _scanDeps: (next) ->
    console.log("scanning dependencies: %s", @_dependencies.map((ops) -> ops.name).join(", "))

    async.map @_dependencies, ((info, next) ->
      amdify { entry: info.path, platform: "browser" }, outcome.e(next).s (bundle) ->
        bundle.name = info.name
        next null, bundle
    ), next

  ###
  ###

  _copyBundles: (bundles, next) ->
    console.log("transforming dependencies into %s", @_pkgDir);
    async.eachSeries bundles, @_copyBundle, next

  ###
  ###

  _copyBundle: (bundle, next) =>
    transformer = new at.Template("amd")
    transformer = new at.Copy({ output: @_cwd + "/" + @_pkgDir }, transformer)

    # dependencies to pluck from being copies
    pluckDeps = @_depNames.filter (depName) -> depName != bundle.name

    console.log("install %s", bundle.name)
    
    # remove deps these
    bundle._deps = bundle._deps.filter (dep) -> 
      !~pluckDeps.indexOf dep.moduleName

    bundle.transform(transformer, next)

  ###
  ###

  _parseConfig: () ->

    pkg = @options.pkg
    cwd = @_cwd = @options.cwd

    deps   = @_depNames = (pkg.nojam?.dependencies ? Object.keys pkg.dependencies)
    ignore = pkg.nojam?.ignore or []
    deps   = deps.filter (dep) -> !~ignore.indexOf dep
    pkgDir = @_pkgDir = pkg.jam?.packageDir ? pkg.nojam.packageDir

    unless pkgDir
      throw new Error "package dir must exist"

    # fetch them
    @_dependencies = deps.map (name) -> 
      path: resolve.sync(name, { basedir: cwd })
      name: name

module.exports = NoJam
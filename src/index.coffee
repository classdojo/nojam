PackageManagers = require "./packageManagers"
Build           = require "./build"
outcome         = require "outcome"

class NoJam

  ###
  ###

  constructor: (ops) ->
    @_packageManager = new PackageManagers()
    @_build          = new Build ops, @_packageManager

  ###
  ###

  rebuild: (callback = ()->) -> @_build.run callback

  ###
  ###

  install: (packages, callback) ->

    @_packageManager.install packages, () => @rebuild callback


module.exports = NoJam


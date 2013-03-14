NPM = require "./npm"
JAM = require "./jam"
async = require "async"

module.exports = class

  ###
  ###

  constructor: (@binName) ->

    @packageManagers = {
      npm: new NPM(),
      jam: new JAM()
    }

    @_all = Object.keys @packageManagers

  ###
  ###

  install: (packages, cb = (() ->)) -> 
    async.forEach packages, ((pkg, next) =>

      pmanagers = @_all


      pm = pkg.split(":")


      if pm.length is 2
        pmanagers = [pm.shift()]
        pkg = pm.shift()
      else
        pkg = pm.shift()

      @_exec pmanagers, ["install", pkg], false, next
    ), cb

  ###
  ###

  upgrade: (cb = (() ->)) -> 
    @_exec @_all, ["upgrade"], true, callback

  ###
  ###

  clearCache: (cb = (() ->)) -> 
    @_exec @_all, ["clearCache"], true, cb


  ###
  ###

  _exec: (packageManagers, args, runAll, callback) ->


    next = () =>
      packageManager = @packageManagers[packageManagers.shift()]

      return callback() if not packageManager

      arg = args.concat()

      packageManager[arg.shift()].call(packageManager, arg, (err, result) ->

        if not err and not runAll
          return callback err, result

        return next()
      )

    next()





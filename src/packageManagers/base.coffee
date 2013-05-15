spawn = require("child_process").spawn
toarray = require "toarray"

module.exports = class

  ###
  ###

  constructor: (@binName) ->

  ###
  ###

  install: (packages, cb) -> @_exec ["install"].concat(packages), cb

  ###
  ###

  upgrade: (cb) -> @_exec ["upgrade"], cb

  ###
  ###

  clearCache: () -> @_exec ["clear-cache"], cb


  ###
  ###

  _exec: (args, callback) ->


    proc = spawn(@binName, args)

    proc.stdout.on "data", (chunk) ->
      process.stdout.write chunk

    proc.stderr.on "data", (chunk) ->
      process.stderr.write chunk

    proc.on "exit", (code) =>
      return callback new Error("#{@binName} #{args[0]} exited with code #{code}") if code
      callback()




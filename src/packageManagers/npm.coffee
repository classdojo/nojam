Base = require "./base"

module.exports = class extends Base
  
  ###
  ###

  constructor: () ->
    super "npm"

  ###
  ###

  upgrade: (cb) -> @_exec ["update"], cb

  ###
  ###

  clearCache: () -> @_exec ["cache", "clear"], cb
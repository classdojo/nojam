Base = require "./base"

module.exports = class extends Base
  
  ###
  ###

  constructor: () ->
    super "jam"


  ###
  ###

  rebuild: (cb) -> @_exec ["rebuild"], cb
  ###
  ###

  clearCache: (cb) -> @_exec ["clear-cache"], cb

  
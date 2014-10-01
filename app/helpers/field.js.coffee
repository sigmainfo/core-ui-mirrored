#= require environment

class Coreon.Helpers.Field

  constructor: (@label, @name, @template, options = {}) ->
    options.id       ?= @name.replace /[\[\]]/g, "_"
    options.required ?= false
    options.errors   ?= []

    @id        = options.id
    @required  = options.required
    @errors    = options.errors
    @value     = options.value
    @class     = options.class
    @type      = options.type

  render: ->
    @template @
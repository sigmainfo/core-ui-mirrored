#= require environment
#= require helpers/render
#= require templates/forms/_field

class Coreon.Helpers.Field

  template: Coreon.Templates['forms/field']

  constructor: (@label, @name, @field_template_name, options = {}) ->
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
    data = {}
    _.pairs(@).map (p) ->
      data[p[0]] = p[1]

    @template data

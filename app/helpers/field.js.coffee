#= require environment
#= require helpers/render
#= require templates/forms/_field

class Coreon.Helpers.Field

  template: Coreon.Templates['forms/field']

  constructor: (@label, @name, @field_template_name, options = {}) ->
    options.id        ?= @name.replace /[\[\]]/g, "_"
    options.required  ?= false
    options.errors    ?= []
    options.autofocus ?= false

    @id        = options.id
    @required  = options.required
    @errors    = options.errors
    @value     = options.value
    @type      = options.type
    @autofocus = options.autofocus

    className        = 'input'
    className        += " #{options.class}" if options.class
    className        += ' required' if @required
    className        += ' error' if @errors.length > 0
    @class     = className

  render: ->
    data = {}
    _.pairs(@).map (p) ->
      data[p[0]] = p[1]

    @template data

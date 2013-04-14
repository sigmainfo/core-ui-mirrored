#= require environment
#= require templates/forms/_input

autoIncrement = 0

class Input

  template: Coreon.Templates["forms/input"]

  constructor: (@name, @attr, @model = null, options = {}) ->
    options.type     ?= "text"
    options.required ?= false
    options.scope    ?= @name

    options.scope   = options.scope.replace "[]", "[#{options.index}]" if options.index?
    dasherizedAttr  = @attr.replace /[A-Z]/, (glyph) -> "-#{glyph.toLowerCase()}"
    underscoredAttr = dasherizedAttr.replace /-/g, "_"
    autoIncremented = options.scope.replace("[]", "[#{autoIncrement}]")
    dasherizedScope = autoIncremented.replace(/\[/g, "-").replace(/]/g, "")
    className       = "input #{dasherizedAttr}"
    className       += " required" if options.required

    @className = className
    @type      = options.type
    @required  = options.required
    @inputName = "#{options.scope}[#{@attr}]"
    @inputId   = "#{dasherizedScope}-#{dasherizedAttr}"
    @value     = if @model? then @model.get @attr else ""
    @label     = options.label or I18n.t "#{@name}.#{underscoredAttr}"

    autoIncrement += 1

  render: ->
    @template @

Coreon.Helpers.input = (name, attr, model, options) ->
  (new Input name, attr, model, options).render()

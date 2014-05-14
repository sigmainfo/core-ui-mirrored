#= require environment

Coreon.Modules.Properties =

  publicProperties: ->
    @properties().models[..]

  hasProperties: ->
    @publicProperties().length > 0

  propertiesByKey: (options = {}) ->
    precedence = options.precedence or []

    properties = @publicProperties().sort (a, b) ->
      [a, b] = [a, b].map (property) ->
        lang = property.get('lang')
        pos = precedence.indexOf lang
        pos = precedence.length if pos < 0
        pos
      a - b

    groups = _(properties).groupBy (property) ->
      property.get('key')

    for key, group of groups
      key: key
      properties: group

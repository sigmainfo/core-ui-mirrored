#= require environment

Coreon.Helpers.render = (template, context) ->
  Coreon.Templates[template] context

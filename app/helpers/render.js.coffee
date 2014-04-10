#= require environment

Coreon.Helpers.render = (id, context) ->
  if template = Coreon.Templates[id]
    template context
  else
    throw "Template not found: #{id}"

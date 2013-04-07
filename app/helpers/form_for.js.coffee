#= require environment
#= require helpers/render
#= require templates/forms/_form_for
#= require templates/forms/_actions

Coreon.Helpers.form_for = (name, model, block) ->
  context = {}
  context[key] = value for key, value of @
  action = if model.isNew() then "create" else "update"
  context.form =
    name: name
    model: model
    yield: -> block.call context
    className: "#{ name.replace /_/g, '-' } #{action}"
    submit: I18n.t "#{name}.#{action}"
  Coreon.Templates["forms/form_for"] context

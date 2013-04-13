#= require environment
#= require lib/form_context
#= require helpers/render
#= require helpers/fields_for
#= require templates/forms/_form_for
#= require templates/forms/_actions

class Form extends Coreon.Lib.FormContext

  template: Coreon.Templates["forms/form_for"]

  constructor: (@name, @model, context, block) ->
    super context, block
    @action = if model.isNew() then "create" else "update"
    @className = "#{ name.replace /_/g, '-' } #{@action}"
    @submit = I18n.t "#{@name}.#{@action}"

  fields_for: (attribute, block) ->
    Coreon.Helpers.fields_for attribute, @model, block
    
Coreon.Helpers.form_for = (name, model, block) ->
  (new Form name, model, @, block).render()

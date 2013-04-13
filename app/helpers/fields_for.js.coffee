#= require environment
#= require lib/form_context
#= require templates/forms/_fields_for

class FieldSet extends Coreon.Lib.FormContext

  template: Coreon.Templates["forms/fields_for"]

  constructor: (@attribute, @model, context, block) ->
    super context, block
    @className = @attribute.replace /[A-Z]/g, (glyph) -> "-#{glyph.toLowerCase()}" 

Coreon.Helpers.fields_for = (attribute, model, block) ->
  (new FieldSet attribute, model, @, block).render()

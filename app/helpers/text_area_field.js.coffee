#= require environment
#= require helpers/field
#= require templates/forms/_text_area_field

class TextAreaField extends Coreon.Helpers.Field

  constructor: (label, name, template, options = {}) ->
    super(label, name, template, options)
    @options = options.options || []
    @allowEmpty = options.allowEmpty || false

Coreon.Helpers.textAreaField = (label, name, options) ->
  (new TextAreaField label, name, 'forms/text_area_field', options).render()
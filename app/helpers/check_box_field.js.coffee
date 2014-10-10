#= require environment
#= require helpers/field
#= require templates/forms/_check_box_field

class CheckBoxField extends Coreon.Helpers.Field

  constructor: (label, name, template, options = {}) ->
    super(label, name, template, options)
    @options = options.options || []
    @allowEmpty = options.allowEmpty || false

Coreon.Helpers.checkBoxField = (label, name, options) ->
  (new CheckBoxField label, name, 'forms/check_box_field', options).render()
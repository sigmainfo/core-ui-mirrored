#= require environment
#= require helpers/field
#= require templates/forms/_multi_select_field

class MultiSelectField extends Coreon.Helpers.Field

  constructor: (label, name, template, options = {}) ->
    super(label, name, template, options)
    @options = options.options || []
    @allowEmpty = options.allowEmpty || false


Coreon.Helpers.multiSelectField = (label, name, options) ->
  (new MultiSelectField label, name, 'forms/multi_select_field', options).render()
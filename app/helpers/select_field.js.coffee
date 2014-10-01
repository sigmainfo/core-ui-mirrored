#= require environment
#= require helpers/field
#= require templates/forms/_select_field

class SelectField extends Coreon.Helpers.Field

  constructor: (label, name, template, options = {}) ->
    super(label, name, template, options)
    @options = options.options || []
    @allowEmpty = options.allowEmpty || false


Coreon.Helpers.selectField = (label, name, options) ->
  (new SelectField label, name, 'forms/select_field', options).render()
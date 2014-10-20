#= require environment
#= require helpers/field
#= require templates/forms/_boolean_field

class BooleanField extends Coreon.Helpers.Field

  constructor: (label, name, template, options = {}) ->
    super(label, name, template, options)
    @labels = options.labels || []

Coreon.Helpers.booleanField = (label, name, options) ->
  (new BooleanField label, name, 'forms/boolean_field', options).render()
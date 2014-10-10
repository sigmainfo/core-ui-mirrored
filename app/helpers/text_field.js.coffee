#= require environment
#= require helpers/field
#= require templates/forms/_text_field

class TextField extends Coreon.Helpers.Field

  constructor: (label, name, template, options = {}) ->
    super(label, name, template, options)
    @allowEmpty = options.allowEmpty || false

Coreon.Helpers.textField = (label, name, options) ->
  (new TextField label, name, 'forms/text_field', options).render()
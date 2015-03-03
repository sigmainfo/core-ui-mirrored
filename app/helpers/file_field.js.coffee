#= require environment
#= require helpers/field
#= require templates/forms/_file_field

class FileField extends Coreon.Helpers.Field

  constructor: (label, name, template, options = {}) ->
    super(label, name, template, options)
    @allowEmpty = options.allowEmpty || false

Coreon.Helpers.fileField = (label, name, options) ->
  (new FileField label, name, 'forms/file_field', options).render()
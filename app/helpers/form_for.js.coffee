#= require environment
#= require lib/form_context
#= require helpers/render
#= require templates/forms/_form_for
#= require templates/forms/_submit

errorCounts = (errorsHash) ->
  counts = {}
  for attr, errors of errorsHash
    unless errorsHash["nested_errors_on_#{attr}"]?
      unless attr.indexOf("nested_errors_on_") is 0
        counts[attr] = errors.length
      else
        counts[attr[17..]] = errorCount errors
  counts

errorCount = (nestedErrors) ->
  count = 0
  for nestedError in nestedErrors
    for attr, errors of nestedError
      unless nestedError["nested_errors_on_#{attr}"]?
        unless attr.indexOf("nested_errors_on_") is 0
          count += errors.length
        else
          count += errorCount errors
  count


class Form extends Coreon.Lib.FormContext

  template: Coreon.Templates["forms/form_for"]

  constructor: (@name, @model, context, block) ->
    super context, block
    @action = if @model.isNew() then "create" else "update"
    @className = "#{ name.replace /_/g, '-' } #{@action}"
    @submit = I18n.t "#{@name}.#{@action}"
    @errors = @model?.errors?()
    @errorCounts = errorCounts @errors if @errors?

Coreon.Helpers.form_for = (name, model, block) ->
  (new Form name, model, @, block).render()

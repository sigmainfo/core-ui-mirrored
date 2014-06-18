#= require environment
#= require lib/form_context
#= require helpers/render
#= require helpers/input
#= require templates/forms/_form_for

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

  constructor: (@name, @model, context, block, options = {}) ->
    super context, block
    @action = if @model.isNew() then 'create' else 'update'
    @errors = @model.errors?()
    @errorCounts = errorCounts @errors if @errors?
    @noCancel = options.noCancel or off
    @submit = options.submit or I18n.t("#{@name}.#{@action}")
    @submitHint = options.submitHint or @submit

  input: (attr, options = {}) ->
    Coreon.Helpers.input @name, attr, @model, options

Coreon.Helpers.form_for = (name, model, options, block) ->
  block = _(arguments).last()
  if arguments.length < 4
    options = {}
  if arguments.length < 3 or model is null
    model = new Backbone.Model

  (new Form name, model, @, block, options).render()

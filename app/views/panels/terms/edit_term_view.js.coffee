#= require environment
#= require templates/terms/new_term
#= require helpers/form_for
#= require helpers/input
#= require views/properties/edit_properties_view
#= require modules/confirmation

class Coreon.Views.Panels.Terms.EditTermView extends Backbone.View

  Coreon.Modules.include @, Coreon.Modules.Confirmation

  template: Coreon.Templates['terms/new_term']

  events:
    "submit form.term.update"           : "updateTerm"
    "click form a.reset:not(.disabled)" : "reset"

  initialize: ->
    @editProperties = new Coreon.Views.Properties.EditPropertiesView
      collection: @model.propertiesWithDefaults(includeUndefined: true)
      optionalProperties: Coreon.Models.RepositorySettings.optionalPropertiesFor('term')
      isEdit: true

  render: ->
    @$el.html @template term: @model
    @$el.find('.submit').before @editProperties.render().$el
    @

  serializeArray: ->
    {
      id: @$el.find("input[name=\"id\"]").val(),
      value: @$el.find("input[name=\"term[value]\"]").val(),
      lang: @$el.find("input[name=\"term[lang]\"]").val(),
      properties: @editProperties.serializeArray()
    }

  updateTerm: (event) ->
    event.preventDefault()
    form = $ event.target
    data = @serializeArray()
    trigger = form.find('[type=submit]')
    elements_to_delete = form.find(".property.delete")

    if elements_to_delete.length > 0
      @confirm
        trigger: trigger
        message: I18n.t "term.confirm_update", count: elements_to_delete.length
        action: =>
          @saveTerm(data)
    else
      @saveTerm(data)

  saveTerm: (attrs) ->
    request = @model.save attrs, wait: yes, attrs: term: attrs
    request.done =>
      Coreon.Models.Notification.info I18n.t("notifications.term.saved", value: @model.get "value")
    request.fail =>
      @model.set attrs
      @render()

  reset: (evt) ->
    evt.preventDefault()
    @model.revert()
    @model.remoteError = null
    @$el.find(".property").removeClass("delete")
    @render()

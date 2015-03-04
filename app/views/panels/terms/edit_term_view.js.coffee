#= require environment
#= require templates/terms/new_term
#= require helpers/form_for
#= require helpers/input
#= require views/properties/edit_properties_view
#= require modules/confirmation
#= require modules/assets
#= require models/term

class Coreon.Views.Panels.Terms.EditTermView extends Backbone.View

  Coreon.Modules.include @, Coreon.Modules.Confirmation
  Coreon.Modules.include @, Coreon.Modules.Assets

  template: Coreon.Templates['terms/new_term']

  events:
    'input input#term-value'            : 'inputChanged'
    'input input#term-lang'             : 'inputChanged'
    "submit form.term.update"           : "updateTerm"
    "submit form.term.create"           : "createTerm"
    "click form a.reset:not(.disabled)" : "reset"

  initialize: (options) ->
    @model = options.model
    @concept = options.concept
    @isEdit = options.isEdit
    @selectableLanguages = Coreon.Models.RepositorySettings.languageOptions()

  render: ->
    @editProperties = new Coreon.Views.Properties.EditPropertiesView
      collection: @model.propertiesWithDefaults(includeUndefined: true)
      optionalProperties: Coreon.Models.RepositorySettings.optionalPropertiesFor('term')
      isEdit: @isEdit
    @listenTo @editProperties, 'updateValid', =>
      @validateForm()

    @$el.html @template term: @model, selectableLanguages: @selectableLanguages
    @$el.find('.submit').before @editProperties.render().$el
    @validateForm()
    @$el.find('select').coreonSelect()
    @

  serializeArray: ->
    {
      concept_id: @concept?.get('id')
      id: @$el.find("input[name=\"id\"]").val(),
      value: @$el.find("input[name=\"term[value]\"]").val(),
      lang: @$el.find("select[name=\"term[lang]\"]").val(),
      properties: @editProperties.serializeArray()
    }

  isValid: ->
    # TODO 20141201 [ap] Re-enable if we want term inputs validation on front end
    #result = @serializeArray()
    # if !result.value? || (result.value is '') || !result.lang? || (result.lang is '') || !@editProperties.isValid()
    #   false
    # else
    #   true
    @editProperties.isValid()

  inputChanged: ->
    @validateForm()

  validateForm: ->
    @$el.find('form .submit button[type=submit]').prop('disabled', !@isValid())

  updateTerm: (event) ->
    event.preventDefault()
    form = $ event.target
    data = @serializeArray()
    trigger = form.find('[type=submit]')
    elements_to_delete = @editProperties.countDeleted()

    if elements_to_delete > 0
      @confirm
        trigger: trigger
        message: I18n.t "term.confirm_update", count: elements_to_delete
        action: =>
          @saveTerm(data)
        restore: => @$el.trigger('restore', [form])
    else
      @saveTerm(data)

  createTerm: ->
    view = @
    data = @serializeArray()
    @model = new Coreon.Models.Term data
    request = @model.save null, wait: yes
    request.done =>
      $.when(
        @saveAssets('term', view.model, view.editProperties.serializeAssetsArray())
      ).done =>
        view.model.fetch
          success: =>
            Coreon.Models.Notification.info I18n.t("notifications.term.created", value: @model.get("value"))
            @concept.terms().add @model
            @trigger 'created'
    request.fail =>
      @render()

  saveTerm: (attrs) ->
    view = @
    request = @model.save attrs, silent: yes, wait: yes, attrs: term: attrs
    request.done =>
      $.when(
        @saveAssets('term', view.model, view.editProperties.serializeAssetsArray())
      ).done =>
        view.model.fetch
          success: ->
            view.model.trigger 'termChanged'
            Coreon.Models.Notification.info I18n.t("notifications.term.saved", value: view.model.get "value")
    request.fail =>
      @model.set attrs
      @render()

  reset: (evt) ->
    evt.preventDefault()
    @model.revert()
    @model.remoteError = null
    @$el.find(".property").removeClass("delete")
    @render()



#= require environment
#= require helpers/render
#= require helpers/form_for
#= require helpers/input
#= require helpers/graph_uri
#= require templates/concepts/_caption
#= require templates/concepts/new_concept
#= require templates/properties/new_property
#= require templates/properties/property_fieldset
#= require templates/concepts/_new_term
#= require views/concepts/shared/broader_and_narrower_view
#= require views/panels/terms/new_term_view
#= require views/properties/edit_properties_view
#= require models/concept
#= require models/notification
#= require jquery.serializeJSON
#= require modules/helpers
#= require modules/nested_fields_for

class Coreon.Views.Panels.Concepts.NewConceptView extends Backbone.View

  Coreon.Modules.extend @, Coreon.Modules.NestedFieldsFor
  Coreon.Modules.include @, Coreon.Modules.Assets

  className: "concept new"

  template: Coreon.Templates["concepts/new_concept"]
  term: Coreon.Templates["concepts/new_term"]

  @nestedFieldsFor "properties", name: "property"

  events:
    "click  a.add-term"        : "addTerm"
    "click  a.remove-term"     : "removeTerm"
    "submit form"              : "create"
    "click .cancel"            : "cancel"

  initialize: (attrs, options = {})->
    @app = options.app or Coreon.application
    @broaderAndNarrower = new Coreon.Views.Concepts.Shared.BroaderAndNarrowerView
      model: @model
    @termViews = []
    @allPropertyViews = []

  render: ->
    termView.remove() for termView in @termViews
    @allPropertyViews = []
    @termViews = []
    @editProperties = new Coreon.Views.Properties.EditPropertiesView
      collection: @model.propertiesWithDefaults()
      optionalProperties: Coreon.Models.RepositorySettings.optionalPropertiesFor('concept')
    @$el.html @template concept: @model
    unless @_wasRendered
      @broaderAndNarrower.render()
    @editProperties.render()
    @$("form").before @broaderAndNarrower.$el
    @$("form .terms").before @editProperties.$el
    @refreshPropertiesValidation @editProperties
    if @model.terms()
      _.each @model.terms().models, (term) =>
        @renderTerm(term)
    @_wasRendered = true
    @

  refreshPropertiesValidation: (propertiesView) ->
    formButton = @$el.find("form .submit button[type=submit]")
    @allPropertyViews.push propertiesView
    @listenTo propertiesView, 'updateValid', =>
      invalid = _.filter @allPropertyViews, (view) ->
        !view.isValid()
      if invalid.length > 0
        formButton.prop('disabled', true)
      else
        formButton.prop('disabled', false)
    propertiesView.updateValid()

  create: (event) ->
    view = @
    event.preventDefault()
    attrs = {}
    attrs.properties = @editProperties.serializeArray()
    attrs.terms = []
    _.each @termViews, (termView) ->
      attrs.terms.push termView.serializeArray()

    termAssets = _.map @termViews, (termView) ->
      termView.serializeAssetsArray()

    request = @model.save attrs

    request.done =>
      $.when(
        view.saveAssets('concept', view.model, view.editProperties.serializeAssetsArray()),
        view.saveTermAssets(view.model, termAssets)
      ).done =>
        Coreon.Models.Notification.info I18n.t("notifications.concept.created", label: view.model.get "label")
        Coreon.Models.Concept.collection().add view.model
        Backbone.history.navigate view.model.path(), trigger: true

    request.fail => @render()

  saveTermAssets: (concept, termAssets) =>
    d = new $.Deferred()
    deferredArr = concept.terms().map (term) =>
      matched = _.filter termAssets, (t) -> (term.get('value') == t.value) && (term.get('lang') == t.lang)
      @saveAssets('term', term, matched[0].properties)
    $.when.apply(@, deferredArr).then ->
      d.resolve()
    d

  cancel: ->
    path = @app.get('repository').path()
    if parentId = @model.get('superconcept_ids')[0]
      path += "/concepts/#{parentId}"
    Backbone.history.navigate path, trigger: true

  remove: ->
    @broaderAndNarrower.remove()
    super

  renderTerm: (term) ->
    index = @termViews.length
    errors = @model.errors()?.nested_errors_on_terms?[index]
    newTermView = new Coreon.Views.Panels.Terms.NewTermView(model: term, index: index, errors: errors)
    @termViews.push newTermView
    @$('form .terms>.add').before newTermView.render().$el
    @refreshPropertiesValidation newTermView.editProperties

  addTerm: ->
    term = new Coreon.Models.Term
    @renderTerm(term)

  removeTerm: (evt) ->
    trigger = $ evt.target
    container = trigger.closest ".term"
    termView = _.find @termViews, (view) -> container.attr('data-index') == "#{view.index}"
    @termViews = _.without @termViews, termView
    termView.remove()



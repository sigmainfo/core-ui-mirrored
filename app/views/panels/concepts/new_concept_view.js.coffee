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

    request = @model.save attrs

    request.done =>
      $.when(
        view.saveAssets('concept', view.model.id, view.editProperties.serializeAssetsArray())
        # @saveAssets('term', @editProperties.serializeAssetsArray()),
      ).done =>
        Coreon.Models.Notification.info I18n.t("notifications.concept.created", label: view.model.get "label")
        Coreon.Models.Concept.collection().add view.model
        Backbone.history.navigate view.model.path(), trigger: true

    request.fail => @render()

  saveAssets: (type, id, assets) ->
    d = new $.Deferred()
    if type is 'concept'
      url = Coreon.Helpers.graphUri("/concepts/#{id}/properties")
    deferredArr = $.map assets, (asset) ->
      formData = new FormData()
      formData.append 'property[key]', asset.key
      formData.append 'property[type]', asset.type
      formData.append 'property[lang]', asset.lang
      formData.append 'property[value]', asset.value
      formData.append 'property[asset]', asset.asset
      Coreon.Modules.CoreAPI.ajax url,
        data: formData,
        processData: false,
        contentType: false,
        type: 'POST'

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



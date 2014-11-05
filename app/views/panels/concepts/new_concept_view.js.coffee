#= require environment
#= require helpers/render
#= require helpers/form_for
#= require helpers/input
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
    #"click  a.remove-property" : "removeProperty"
    "click  a.add-term"        : "addTerm"
    "click  a.remove-term"     : "removeTerm"
    "submit form"              : "create"
    "click .cancel"            : "cancel"

  initialize: (attrs, options = {})->
    @app = options.app or Coreon.application
    @broaderAndNarrower = new Coreon.Views.Concepts.Shared.BroaderAndNarrowerView
      model: @model
    @termViews = []

  render: ->
    termView.remove() for termView in @termViews
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
    if @model.terms().length > 0
      _.each @model.terms().models, (term) =>
        @renderTerm(term)
    @_wasRendered = true
    @

  refreshPropertiesValidation: (propertiesView) ->
    propertiesView.$el.closest('form').find(".submit button[type=submit]").prop('disabled', !propertiesView.isValid())
    @listenTo propertiesView, 'updateValid', ->
      propertiesView.$el.closest('form').find(".submit button[type=submit]").prop('disabled', !propertiesView.isValid())

  create: (event) ->
    event.preventDefault()
    attrs = {}
    attrs.properties = @editProperties.serializeArray()
    attrs.terms = []
    _.each @termViews, (termView) ->
      attrs.terms.push termView.serializeArray()

    request = @model.save attrs

    request.done =>
      Coreon.Models.Notification.info I18n.t("notifications.concept.created", label: @model.get "label")
      Coreon.Models.Concept.collection().add @model
      Backbone.history.navigate @model.path(), trigger: true

    request.fail => @render()

  cancel: ->
    path = @app.get('repository').path()
    if parentId = @model.get('superconcept_ids')[0]
      path += "/concepts/#{parentId}"
    Backbone.history.navigate path, trigger: true

  remove: ->
    @broaderAndNarrower.remove()
    super

  renderTerm: (term) ->
    terms = @$("form .terms")
    index = @termViews.length
    errors = @model.errors()?.nested_errors_on_terms?[index]
    newTermView = new Coreon.Views.Panels.Terms.NewTermView(model: term, index: index, errors: errors)
    @termViews.push newTermView
    @$('form .terms>.add').before newTermView.render().$el

  addTerm: ->
    term = new Coreon.Models.Term
    @renderTerm(term)


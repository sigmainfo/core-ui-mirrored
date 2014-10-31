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
    @editProperties = new Coreon.Views.Properties.EditPropertiesView
      collection: @model.propertiesWithDefaults()
      optionalProperties: Coreon.Models.RepositorySettings.propertiesFor('concept')
    @termProperties = []
    @termIndex = 0

  render: ->
    @termCount = if @model.has("terms") then @model.get("terms").length else 0
    @$el.html @template concept: @model
    unless @_wasRendered
      @broaderAndNarrower.render()
      @editProperties.render()
    @$("form").before @broaderAndNarrower.$el
    @$("form .terms").before @editProperties.$el
    @$el.find("form .submit button[type=submit]").prop('disabled', !@editProperties.isValid())
    @listenTo @editProperties, 'updateValid', =>
      @$el.find("form .submit button[type=submit]").prop('disabled', !@editProperties.isValid())
    @_wasRendered = true
    @

  create: (event) ->
    event.preventDefault()
    data = @$("form").serializeJSON() or {}
    attrs = {}
    attrs.properties = @editProperties.serializeArray()
    attrs.terms = []
    for term in data.terms
      attrs.terms.push term

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

  addTerm: ->
    terms = @$("form .terms")
    term = new Coreon.Models.Term
    termNode = $ @term term: term, index: @termIndex
    @$('form .terms>.add').before termNode
    @newTermPropertiesView(term, termNode, @termIndex)
    @termIndex++

  newTermPropertiesView: (term, termNode, termIndex) ->
    @termProperties = []
    termProperty = new Coreon.Views.Properties.EditPropertiesView
      collection: term.propertiesWithDefaults()
      optionalProperties: Coreon.Models.RepositorySettings.optionalPropertiesFor('term')
      isEdit: true
      collapsed: true
      ownerId: termIndex
    @termProperties.push termProperty
    termNode.append termProperty.render().$el
    # @$el.find("form .submit button[type=submit]").prop('disabled', !termProperty.isValid())
    # @listenTo termProperty, 'updateValid', ->
    #   @$el.find("form .submit button[type=submit]").prop('disabled', !termProperty.isValid())

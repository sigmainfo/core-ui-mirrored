#= require environment
#= require helpers/render
#= require helpers/form_for
#= require helpers/input
#= require templates/concepts/_caption
#= require templates/concepts/new_concept
#= require templates/properties/new_property
#= require templates/concepts/_new_term
#= require views/concepts/shared/broader_and_narrower_view
#= require models/concept
#= require models/notification
#= require jquery.serializeJSON
#= require modules/helpers
#= require modules/nested_fields_for

class Coreon.Views.Concepts.NewConceptView extends Backbone.View

  Coreon.Modules.extend @, Coreon.Modules.NestedFieldsFor

  className: "concept new"

  template: Coreon.Templates["concepts/new_concept"]

  @nestedFieldsFor "properties", name: "property"
  @nestedFieldsFor "terms", template: Coreon.Templates["concepts/new_term"]

  events:
    "click  a.add-property"    : "addProperty"
    "click  a.remove-property" : "removeProperty"
    "click  a.add-term"        : "addTerm"
    "click  a.remove-term"     : "removeTerm"
    "submit form"              : "create"

  initialize: ->
    @broaderAndNarrower = new Coreon.Views.Concepts.Shared.BroaderAndNarrowerView
      model: @model

  render: ->
    @termCount = if @model.has("terms") then @model.get("terms").length else 0
    @$el.html @template concept: @model
    @broaderAndNarrower.render() unless @_wasRendered
    @$("form").before @broaderAndNarrower.$el
    @_wasRendered = true
    @

  create: (event) ->
    event.preventDefault()
    data = @$("form").serializeJSON().concept or {}
    attrs = {}
    attrs.properties = if data.properties?
      property for property in data.properties when property?
    else []
    attrs.terms = if data.terms?
      term for term in data.terms when term?
    else []
    @$("form").find("input,button").prop "disabled", true
    @model.save attrs,
      success: =>
        Coreon.Models.Notification.info I18n.t("notifications.concept.created", label: @model.get "label")
        Coreon.Models.Concept.collection().add @model
        Backbone.history.navigate @model.url(), trigger: true
      error: =>
        @model.once "error", @render, @

  remove: ->
    @broaderAndNarrower.remove()
    super

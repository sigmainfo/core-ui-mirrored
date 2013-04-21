#= require environment
#= require helpers/render
#= require helpers/form_for
#= require helpers/input
#= require templates/concepts/_caption
#= require templates/concepts/new_concept
#= require templates/properties/new_property
#= require templates/terms/new_term
#= require views/concepts/shared/broader_and_narrower_view
#= require models/concept
#= require jquery.serializeJSON
#= require modules/messages

class Coreon.Views.Concepts.NewConceptView extends Backbone.View

  className: "concept new"

  template: Coreon.Templates["concepts/new_concept"]
  property: Coreon.Templates["properties/new_property"]
  term: Coreon.Templates["terms/new_term"]

  events:
    "click  a.add-property"    : "addProperty"
    "click  a.remove-property" : "removeProperty"
    "click  a.add-term"        : "addTerm"
    "click  a.remove-term"     : "removeTerm"
    "submit form"              : "create"

  initialize: ->
    @broaderAndNarrower = new Coreon.Views.Concepts.Shared.BroaderAndNarrowerView
      model: @model
    @termCount = 0

  render: ->
    @propCount = if @model.has("properties") then @model.get("properties").length else 0
    @termCount = if @model.has("terms") then @model.get("terms").length else 0
    @$el.html @template concept: @model
    @broaderAndNarrower.render() unless @_wasRendered
    @$("form").before @broaderAndNarrower.$el
    @_wasRendered = true
    @

  addProperty: (event) ->
    @propCount += 1
    @$(".properties").append @property index: @propCount - 1

  removeProperty: (event) ->
    $(event.target).closest(".property").remove()

  addTerm: (event) ->
    @termCount += 1
    @$(".terms").append @term index: @termCount - 1

  removeTerm: (event) ->
    $(event.target).closest(".term").remove()

  create: (event) ->
    event.preventDefault()
    attrs = @$("form").serializeJSON().concept or {}
    attrs.properties ?= []
    attrs.terms ?= []
    @$("form").find("input,button").attr("disabled", true)
    #TODO: use success and error callbacks to resume from options on reauth
    @model.save(attrs)
      .done =>
        Coreon.Models.Concept.collection().add @model
        Backbone.history.navigate @model.url(), trigger: true
      .fail =>
        @render()

  remove: ->
    @broaderAndNarrower.remove()
    super

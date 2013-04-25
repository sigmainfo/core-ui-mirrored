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

  render: ->
    @termCount = if @model.has("terms") then @model.get("terms").length else 0
    @$el.html @template concept: @model
    @broaderAndNarrower.render() unless @_wasRendered
    @$("form").before @broaderAndNarrower.$el
    @_wasRendered = true
    @

  addProperty: (event) ->
    $target = $(event.target)
    $properties = $target.closest(".properties")
    console.log $properties.find("input:last").attr("name")
    nextIndex = if name = $properties.find("input:last").attr("name")
      name.match(/\[(\d+)\]\[[^\]]+\]$/)[1] * 1 + 1
    else
      0
    $properties.find(".actions").before @property
      index: nextIndex
      scope: $target.data "scope"

  removeProperty: (event) ->
    $(event.target).closest(".property").remove()

  addTerm: (event) ->
    @termCount += 1
    @$(".terms .actions").before @term index: @termCount - 1

  removeTerm: (event) ->
    $(event.target).closest(".term").remove()

  create: (event) ->
    event.preventDefault()
    data = @$("form").serializeJSON().concept or {}
    attrs = {}
    attrs.properties = if data.properties? then (property for property in data.properties when property?) else []
    attrs.terms = if data.terms? then (term for term in data.terms when term?) else []
    @$("form").find("input,button").attr("disabled", true)
    @model.save attrs,
      success: =>
        Coreon.Models.Concept.collection().add @model
        Backbone.history.navigate @model.url(), trigger: true
      error: =>
        @model.once "error", @render, @

  remove: ->
    @broaderAndNarrower.remove()
    super

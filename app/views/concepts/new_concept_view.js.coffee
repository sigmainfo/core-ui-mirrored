#= require environment
#= require helpers/render
#= require helpers/form_for
#= require helpers/input
#= require templates/concepts/_caption
#= require templates/concepts/new_concept
#= require templates/properties/new_property
#= require views/concepts/shared/broader_and_narrower_view
#= require models/concept
#= require jquery.serializeJSON

class Coreon.Views.Concepts.NewConceptView extends Backbone.View

  className: "concept new"

  template: Coreon.Templates["concepts/new_concept"]
  property: Coreon.Templates["properties/new_property"]

  events:
    "click  a.add-property"    : "addProperty"
    "click  a.remove-property" : "removeProperty"
    "submit form"              : "create"

  initialize: ->
    @broaderAndNarrower = new Coreon.Views.Concepts.Shared.BroaderAndNarrowerView
      model: @model
    @propCount = 0

  render: ->
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

  create: (event) ->
    event.preventDefault()
    attrs = @$("form").serializeJSON().concept
    @model.save(attrs)
      .done =>
        Coreon.Models.Concept.collection().add @model
        Backbone.history.navigate @model.url(), trigger: true

  remove: ->
    @broaderAndNarrower.remove()
    super

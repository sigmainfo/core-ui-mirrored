#= require environment
#= require helpers/render
#= require helpers/form_for
#= require templates/concepts/_caption
#= require templates/concepts/new_concept
#= require views/concepts/shared/broader_and_narrower_view

class Coreon.Views.Concepts.NewConceptView extends Backbone.View

  className: "concept new"

  template: Coreon.Templates["concepts/new_concept"]

  initialize: ->
    @broaderAndNarrower = new Coreon.Views.Concepts.Shared.BroaderAndNarrowerView
      model: @model

  render: ->
    @$el.html @template concept: @model
    @broaderAndNarrower.render() unless @_wasRendered
    @$("form").before @broaderAndNarrower.$el
    @_wasRendered = true
    @

  remove: ->
    @broaderAndNarrower.remove()
    super

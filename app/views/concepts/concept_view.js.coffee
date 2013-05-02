#= require environment
#= require views/composite_view
#= require helpers/render
#= require templates/concepts/concept
#= require templates/concepts/_caption
#= require templates/shared/info
#= require views/concepts/shared/broader_and_narrower_view
#= require views/properties/properties_view
#= require views/terms/terms_view

class Coreon.Views.Concepts.ConceptView extends Coreon.Views.CompositeView

  className: "concept"

  template: Coreon.Templates["concepts/concept"]

  events:
    "click .system-info-toggle:not(.terms *)" : "toggleInfo"
    "click section *:first-child"             : "toggleSection"

  initialize: ->
    super
    @broaderAndNarrower = new Coreon.Views.Concepts.Shared.BroaderAndNarrowerView
      model: @model
    @model.on "change", @render, @

  render: ->
    @$el.html @template concept: @model
    @broaderAndNarrower.render() unless @_wasRendered
    @$el.children(".system-info").after @broaderAndNarrower.$el

    if @model.get("terms")?.length > 0
      @append new Coreon.Views.Terms.TermsView model: @model

    @_wasRendered = true
    super

  toggleInfo: ->
    @$(".system-info").not(".terms *").slideToggle()

  toggleSection: (event) ->
    $(event.target).next().slideToggle()

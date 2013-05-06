#= require environment
#= require helpers/render
#= require templates/concepts/concept
#= require templates/concepts/_caption
#= require templates/concepts/_info
#= require templates/concepts/_properties
#= require views/concepts/shared/broader_and_narrower_view

class Coreon.Views.Concepts.ConceptView extends Backbone.View

  className: "concept show"

  template: Coreon.Templates["concepts/concept"]

  events:
    "click .system-info-toggle:not(.terms *)" : "toggleInfo"
    "click section *:first-child"             : "toggleSection"
    "click .properties .index li"             : "selectProperty"

  initialize: ->
    @broaderAndNarrower = new Coreon.Views.Concepts.Shared.BroaderAndNarrowerView model: @model
    @listenTo @model, "change", @render

  render: ->
    @$el.html @template concept: @model
    @broaderAndNarrower.render() unless @_wasRendered
    @$el.children(".system-info").after @broaderAndNarrower.$el
    @_wasRendered = true
    @

  toggleInfo: ->
    @$(".system-info").not(".terms *").slideToggle()

  toggleSection: (event) ->
    $target = $(event.target)
    $target.closest("section").toggleClass "collapsed"
    $target.next().slideToggle()

  selectProperty: (event) ->
    $target = $ event.target
    container = $target.closest ".properties"
    container.find("li.selected").removeClass "selected"
    container.find(".values li").eq($target.data "index").add($target).addClass "selected"

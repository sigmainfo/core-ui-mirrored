#= require environment
#= require helpers/render
#= require helpers/can
#= require helpers/form_for
#= require helpers/input
#= require templates/concepts/concept
#= require templates/concepts/_caption
#= require templates/concepts/_info
#= require templates/concepts/_properties
#= require templates/terms/new_term
#= require views/concepts/shared/broader_and_narrower_view

class Coreon.Views.Concepts.ConceptView extends Backbone.View

  className: "concept show"

  template: Coreon.Templates["concepts/concept"]
  term:     Coreon.Templates["terms/new_term"]

  events:
    "click .system-info-toggle"     : "toggleInfo"
    "click section > *:first-child" : "toggleSection"
    "click .properties .index li"   : "selectProperty"
    "click .add-term"               : "addTerm"

  initialize: ->
    @broaderAndNarrower = new Coreon.Views.Concepts.Shared.BroaderAndNarrowerView model: @model
    @listenTo @model, "change", @render

  render: ->
    @$el.html @template concept: @model
    @broaderAndNarrower.render() unless @_wasRendered
    @$el.children(".system-info").after @broaderAndNarrower.$el
    @_wasRendered = true
    @

  toggleInfo: (event )->
    $target = $(event.target)
    $target.next(".system-info")
      .add( $target.siblings(".properties").find ".system-info" )
      .slideToggle()

  toggleSection: (event) ->
    $target = $(event.target)
    $target.closest("section").toggleClass "collapsed"
    $target.next().slideToggle()

  selectProperty: (event) ->
    $target = $ event.target
    container = $target.closest "td"
    container.find("li.selected").removeClass "selected"
    container.find(".values > li").eq($target.data "index").add($target).addClass "selected"

  addTerm: ->
    @new_term = new Coreon.Models.Term
    $terms = @$(".terms")
    $terms.find(".edit").hide()
    $terms.append @term term: @new_term

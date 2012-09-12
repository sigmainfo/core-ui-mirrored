#= require environment
#= require views/main/search_results_terms_view
#= require views/main/search_results_concepts_view
#= require views/main/search_results_tnodes_view

class Coreon.Views.Main.SearchResultsView extends Backbone.View

  initialize: ->
    @subviews = []
    for key, value of @model
      @[key] = new Coreon.Views.Main["SearchResults#{key[0].toUpperCase() + key[1..-1]}View"]
        model: value
      @subviews.push @[key]

  render: ->
    @$el.empty()
    @terms.render().$el.appendTo @$el
    @concepts.render().$el.appendTo @$el
    @tnodes.render().$el.appendTo @el
    @

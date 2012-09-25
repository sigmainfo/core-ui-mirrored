#= require environment
#= require views/composite_view
#= require views/search/search_results_terms_view
#= require views/search/search_results_concepts_view
#= require views/search/search_results_tnodes_view

class Coreon.Views.Search.SearchResultsView extends Coreon.Views.CompositeView

  className: "search-results"

  initialize: () ->
    super
    for key, value of @options.models
      @[key] = new Coreon.Views.Search["SearchResults#{key[0].toUpperCase() + key[1..-1]}View"]
        model: value
      @subviews.push @[key]

  render: ->
    @$el.empty()
    @terms.render().$el.appendTo @$el
    @concepts.render().$el.appendTo @$el
    @tnodes.render().$el.appendTo @el
    @

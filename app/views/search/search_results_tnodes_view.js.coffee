#= require environment
#= require templates/search/search_results_tnodes
#= require models/taxonomy_node

class Coreon.Views.Search.SearchResultsTnodesView extends Coreon.Views.CompositeView

  className: "search-results-tnodes"

  template: Coreon.Templates["search/search_results_tnodes"]
  
  initialize: ->
    super
    @model.on "change", @render, @

  render: ->
    tnodes = for hit, index in @model.get "hits"
      break if index is 10
      new Coreon.Models.TaxonomyNode hit.result
    @$el.html @template tnodes: tnodes
    @

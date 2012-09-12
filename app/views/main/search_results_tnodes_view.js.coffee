#= require environment
#= require templates/main/search_results_tnodes

class Coreon.Views.Main.SearchResultsTnodesView extends Backbone.View

  className: "search-results-tnodes"

  template: Coreon.Templates["main/search_results_tnodes"]
  
  initialize: ->
    @model.on "change", @render, @

  render: ->
    tnodes = _(@model.get "hits").pluck("result")[0..9]
    @$el.html @template tnodes: tnodes
    @

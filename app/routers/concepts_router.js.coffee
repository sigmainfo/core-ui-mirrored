#= require environment

class Coreon.Routers.ConceptsRouter extends Backbone.Router

  routes:
    "concepts/search": "search"

  initialize: (collection) ->
    @collection = collection

  search: (params) ->
    @collection.fetch data:
      "search[query]": params.q

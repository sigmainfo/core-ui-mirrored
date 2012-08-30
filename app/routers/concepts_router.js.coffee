#= require environment
#= require backbone.queryparams

class Coreon.Routers.ConceptsRouter extends Backbone.Router

  routes:
    "concepts/search"         : "search"
    "concepts/search/:target" : "search"

  initialize: (collection) ->
    @collection = collection

  search: (target, params) ->
    params = _(arguments).last()
    data = "search[query]": params.q
    data["search[target]"] = target if arguments.length > 1
    @collection.fetch data: data

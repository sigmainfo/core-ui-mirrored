#= require environment
#= require models/search
#= require models/concept
#= require collections/hits

class Coreon.Models.ConceptSearch extends Coreon.Models.Search

  defaults: ->
    defaults = super
    defaults.path = 'concepts/search'
    defaults

  fetch: (options = {}) ->
    success = options.success
    options.success = (model, response, options) ->
      success arguments... if success?
      hits = []
      for hit in response.hits
        hits.push
          score: hit.score
          result: Coreon.Models.Concept.upsert hit.result
      Coreon.Collections.Hits.collection().reset hits
    super options

  results: ->
    Coreon.Collections.Hits.collection().pluck 'result'

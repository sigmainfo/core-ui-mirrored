#= require environment
#= require models/search
#= require models/concept

class Coreon.Models.ConceptSearch extends Coreon.Models.Search

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

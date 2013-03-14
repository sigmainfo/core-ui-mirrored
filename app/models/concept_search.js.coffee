#= require environment
#= require models/search
#= require models/concept

class Coreon.Models.ConceptSearch extends Coreon.Models.Search

  fetch: (options = {}) ->
    super.done (data) ->
      results = []
      hits    = []
      for hit in data.hits
        results.push hit.result
        hits.push
          _id: hit.result[Coreon.Models.Concept::idAttribute]
          score: hit.score
      Coreon.Models.Concept.upsert results
      Coreon.application?.hits.reset hits

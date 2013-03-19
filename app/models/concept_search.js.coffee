#= require environment
#= require models/search
#= require models/concept

class Coreon.Models.ConceptSearch extends Coreon.Models.Search

  fetch: (options = {}) ->
    success = options.success
    options.success = (model, response, options) ->
      success arguments... if success?
      results = []
      hits    = []
      for hit in response.hits
        results.push hit.result
        hits.push
          _id: hit.result[Coreon.Models.Concept::idAttribute]
          score: hit.score
      Coreon.Models.Concept.upsert results
      Coreon.application?.hits.reset hits
    super options


  # fetch: (options = {}) ->
  #   super.done (data) ->
  #     hits = []
  #     for hit in data.hits
  #       id = hit.result[Coreon.Models.Concept::idAttribute]
  #       concept = Coreon.Models.Concept.find id
  #       hits.push
  #         score: hit.score
  #         result: concept.set hit.result
  #     Coreon.application?.hits.reset hits

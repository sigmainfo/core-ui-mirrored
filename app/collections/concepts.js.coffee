#= require environment
#= require models/concept 

class Coreon.Collections.Concepts extends Backbone.Collection

  model: Coreon.Models.Concept

  url: "concepts"

  getOrFetch: (id) ->
    @get(id) or @addAndFetch(id)

  addAndFetch: (id) ->
    attrs = {}
    attrs[@model::idAttribute] = id
    @add attrs
    model = @get id
    model.fetch()
    model

  addOrUpdate: (models) ->
    models = [models] unless _(models).isArray()
    for model in models
      id = model[@model::idAttribute]
      if old = @get id
        old.set model
      else
        @add model

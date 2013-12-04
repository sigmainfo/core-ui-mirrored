#= require environment
#= require models/term
#= require collections/hits

collection = null

class Coreon.Collections.Terms extends Backbone.Collection

  @collection: ->
    unless collection?

      collection = new @
      hits = Coreon.Collections.Hits.collection()

      updateFromHits = ->
        terms = hits.pluck('result').reduce (terms, concept) ->
          terms = terms.concat concept.terms().models
          terms
        , []
        collection.reset terms

      collection.listenTo hits, 'update', updateFromHits

    collection

  model: Coreon.Models.Term

  comparator: (a, b) ->
    a.get('value').localeCompare b.get('value')

  toJSON: ->
    term.term for term in super

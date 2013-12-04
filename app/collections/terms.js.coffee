#= require environment
#= require models/term
#= require collections/hits

class Coreon.Collections.Terms extends Backbone.Collection

  @collection: ->

    unless @_collection?
      @_collection = new @
      hits = Coreon.Collections.Hits.collection()

      update = =>
        @_collection.stopListening()

        concepts = hits.pluck('result')
        for concept in concepts
          @_collection.listenTo concept, 'change:terms', update
        @_collection.listenTo hits, 'update', update

        terms = concepts.reduce (terms, concept) ->
          terms = terms.concat concept.terms().models
          terms
        , []
        @_collection.reset terms

      @_collection.listenTo hits, 'update', update

    @_collection

  model: Coreon.Models.Term

  comparator: (a, b) ->
    a.get('value').localeCompare b.get('value')

  lang: (lang) ->
    @where lang: lang

  toJSON: ->
    term.term for term in super

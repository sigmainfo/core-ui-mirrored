#= require environment
#= require models/term
#= require collections/hits
#= require modules/core_api

class Coreon.Collections.Terms extends Backbone.Collection

  @hits: ->

    unless @_hits?
      @_hits = new @
      hits = Coreon.Collections.Hits.collection()

      update = =>
        @_hits.stopListening()

        concepts = hits.pluck('result')
        for concept in concepts
          @_hits.listenTo concept, 'change:terms', update
        @_hits.listenTo hits, 'update', update

        terms = concepts.reduce (terms, concept) ->
          terms = terms.concat concept.terms().models
          terms
        , []
        @_hits.reset terms

      @_hits.listenTo hits, 'update', update

    @_hits

  model: Coreon.Models.Term

  urlRoot: 'terms'

  comparator: (a, b) ->
    a.get('value').localeCompare b.get('value')

  lang: (lang) ->
    @where lang: lang

  toJSON: ->
    term.term for term in super

  fetch: ( lang, options = {} ) ->
    throw new Error 'No language given' unless lang?
    options.url ?= "#{@urlRoot}/#{lang}"
    super options

  sync: ( method, model, options )->
    Coreon.Modules.CoreAPI.sync method, model, options

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
          terms.concat concept.terms().models
        , []
        @_hits.reset terms

      @_hits.listenTo hits, 'update', update
    @_hits

  model: Coreon.Models.Term

  url: ->
    "#{Coreon.application.graphUri()}terms"

  comparator: (a, b) ->
    [a, b] = [a, b].map (term) ->
      precedence =
        if property = term.properties().findWhere(key: 'precedence')
          property.get('value')
        else
          null
      sortKey = term.get('sort_key') or null

      precedence: precedence
      sortKey: sortKey

    unless a.precedence is b.precedence
      if a.precedence is null
        1
      else if b.precedence is null
        -1
      else if a.precedence < b.precedence
        -1
      else
        1
    else
      if a.sortKey is b.sortKey
        0
      else if a.sortKey < b.sortKey
        -1
      else
        1

  lang: (lang) ->
    lang = lang?.toLowerCase()
    @filter (term) ->
      term.get('lang').toLowerCase() is lang

  langs: ->
    _.uniq @pluck('lang')

  hasProperties: ->
    @any (term) -> term.hasProperties()

  toJSON: ->
    term.term for term in super

  fetch: ( lang, options = {} ) ->
    throw new Error 'No language given' unless lang?
    unless options.url?
      options.url = "#{@url()}/list/#{encodeURIComponent lang}"
      options.order or= 'asc'
      options.url += "/#{options.order}"
      delete options.order
      if options.from
        options.url += "/#{ options.from }"
        delete options.from
    super options

  sync: ( method, model, options )->
    Coreon.Modules.CoreAPI.sync method, model, options

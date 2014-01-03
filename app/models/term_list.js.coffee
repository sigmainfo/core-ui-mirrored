#= require environment
#= require collections/terms

class Coreon.Models.TermList extends Backbone.Model

  defaults: ->
    source: null
    target: null
    scope: 'hits'

  initialize: ->
    @terms = new Coreon.Collections.Terms
    @stopListening()
    @listenTo @, 'change:source change:scope', @update

  update: ->
    source = @get 'source'
    scope  = @get 'scope'
    terms  =
      if scope is 'hits' and source?
        Coreon.Collections.Terms.hits().lang source
      else
        []
    @terms.reset terms
    if scope is 'all' and source?
      @terms.fetch source
    @trigger 'update', @terms, @attributes

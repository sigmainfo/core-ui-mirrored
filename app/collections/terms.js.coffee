#= require environment
#= require models/term

collection = null

class Coreon.Collections.Terms extends Backbone.Collection

  @collection: ->
    collection ?= new @

  model: Coreon.Models.Term

  comparator: (a, b) ->
    a.get('value').localeCompare b.get('value')

  toJSON: ->
    term.term for term in super

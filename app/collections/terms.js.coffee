#= require environment
#= require models/term

class Coreon.Collections.Terms extends Backbone.Collection

  model: Coreon.Models.Term

  toJSON: ->
    term.term for term in super
#= require environment

class Coreon.Models.Term extends Backbone.Model

  defaults: ->
    properties: []
    value: ""
    lang: ""

  info: ->
    info = id: @id
    defaults = ( key for key, value of @defaults() )
    defaults.push @idAttribute
    for key, value of @attributes when key not in defaults
      info[key] = value
    info

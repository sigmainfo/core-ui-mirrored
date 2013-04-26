#= require environment
#= require modules/helpers
#= require modules/embeds_many

class Coreon.Models.Term extends Backbone.Model

  Coreon.Modules.extend @, Coreon.Modules.EmbedsMany
  
  @embedsMany "properties"

  defaults: ->
    properties: []
    value: ""
    lang: ""
    concept_id: ""

  info: ->
    info = id: @id
    defaults = ( key for key, value of @defaults() )
    defaults.push @idAttribute
    for key, value of @attributes when key not in defaults
      info[key] = value
    info

  validationFailure: (errors) ->
    @trigger "validationFailure", errors

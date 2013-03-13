#= require environment

class Coreon.Models.Term extends Backbone.Model

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

  toJSON: (options) ->
    json = _.clone this.attributes
    delete json.concept_id if not json.concept_id
    json

  validationFailure: (errors) ->
    @trigger "validationFailure", errors

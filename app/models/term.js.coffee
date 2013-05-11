#= require environment
#= require modules/helpers
#= require modules/embeds_many
#= require models/property
#= require modules/system_info
#= require modules/properties_by_key

class Coreon.Models.Term extends Backbone.Model

  Coreon.Modules.extend @, Coreon.Modules.EmbedsMany
  
  @embedsMany "properties", model: Coreon.Models.Property

  Coreon.Modules.include @, Coreon.Modules.SystemInfo
  Coreon.Modules.include @, Coreon.Modules.PropertiesByKey

  defaults: ->
    properties: []
    value: ""
    lang: ""
    concept_id: ""

  urlRoot: ->
    "/concepts/#{@get "concept_id"}/terms"

  toJSON: ->
    json = {}
    json[attr] = value for attr, value of super when attr isnt "concept_id"
    term: json
    
  sync: (method, model, options = {}) ->
    Coreon.application?.sync method, model, options

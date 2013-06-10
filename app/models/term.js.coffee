#= require environment
#= require modules/helpers
#= require modules/embeds_many
#= require models/property
#= require modules/system_info
#= require modules/properties_by_key
#= require modules/remote_validation

class Coreon.Models.Term extends Backbone.Model

  Coreon.Modules.extend @, Coreon.Modules.EmbedsMany
  
  @embedsMany "properties", model: Coreon.Models.Property

  Coreon.Modules.include @, Coreon.Modules.SystemInfo
  Coreon.Modules.include @, Coreon.Modules.PropertiesByKey
  Coreon.Modules.include @, Coreon.Modules.RemoteValidation

  defaults: ->
    properties: []
    value: ""
    lang: ""
    concept_id: ""

  urlRoot: ->
    "/concepts/#{@get "concept_id"}/terms"

  initialize: ->
    @remoteValidationOn()
    @once "destroy", @onDestroy, @

  toJSON: ->
    json = {}
    json[attr] = value for attr, value of super when attr isnt "concept_id"
    term: json

  save: ->
    super

  sync: (method, model, options = {}) ->
    @once "sync", @onCreate, @ if method is "create"
    @once "sync", @onSave, @ if method is "update"
    Coreon.application?.sync method, model, options

  onCreate: ->
    @trigger "create", @, @.id
    @message I18n.t("term.created", value: @get "value"), type: "info"

  onDestroy: ->
    @message I18n.t("term.deleted", value: @get "value"), type: "info"

  onSave: ->
    @message I18n.t("term.saved", value: @get "value"), type: "info"

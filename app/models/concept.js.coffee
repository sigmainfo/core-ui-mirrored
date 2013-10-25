#= require environment
#= require modules/helpers
#= require modules/accumulation
#= require modules/embeds_many
#= require collections/terms
#= require models/property
#= require modules/system_info
#= require modules/properties_by_key
#= require modules/remote_validation
#= require modules/persisted_attributes
#= require modules/core_api
#= require collections/hits
#= require collections/concepts

class Coreon.Models.Concept extends Backbone.Model

  Coreon.Modules.extend @, Coreon.Modules.Accumulation

  @collection = ->
    @_collection ||= new Coreon.Collections.Concepts

  Coreon.Modules.extend @, Coreon.Modules.EmbedsMany

  @embedsMany "properties", model: Coreon.Models.Property
  @embedsMany "terms", collection: Coreon.Collections.Terms

  Coreon.Modules.include @, Coreon.Modules.SystemInfo
  Coreon.Modules.include @, Coreon.Modules.PropertiesByKey
  Coreon.Modules.include @, Coreon.Modules.RemoteValidation
  Coreon.Modules.include @, Coreon.Modules.PersistedAttributes

  urlRoot: "/concepts"

  defaults: ->
    properties: []
    terms: []
    superconcept_ids: []
    subconcept_ids: []
    label: ""
    hit: null

  initialize: (attrs, options) ->
    @set "label", @_label(), silent: true
    @on "change:#{@idAttribute} change:terms change:properties", @_updateLabel, @
    @_updateHit()
    @listenTo Coreon.Collections.Hits.collection(), "reset add remove", @_updateHit
    @remoteValidationOn()
    @once "sync", @syncMessage, @ if @isNew()
    @persistedAttributesOn()

  termsByLang: ->
    terms = {}
    for term in @terms().models
      lang = term.get "lang"
      terms[lang] ?= []
      terms[lang].push term
    terms

  toJSON: (options) ->
    serialized = {}
    for key, value of @attributes when key not in ["hit", "label"]
      serialized[key] = value
    concept: serialized

  _updateLabel: ->
    @set "label", @_label()

  _updateHit: ->
    @set "hit", Coreon.Collections.Hits.collection().findByResult(@)

  _label: ->
    if @isNew()
      I18n.t "concept.new_concept"
    else
      @_propLabel() or @_termLabel() or @id

  _propLabel: ->
    _(@get "properties")?.find( (prop) -> prop.key is "label" )?.value

  _termLabel: ->
    terms = @get "terms"
    for term in terms
      if term.lang?.match /^en/i
        label = term.value
        break
    label ?= terms[0]?.value
    label

  acceptsConnection: (item_id)->
    item_id != @id &&
      @get("superconcept_ids").indexOf(item_id) == -1 &&
        @get("subconcept_ids").indexOf(item_id) == -1

  sync: (method, model, options = {}) ->
    @once "sync", @onCreate, @ if method is "create"
    options.batch = on
    Coreon.Modules.CoreAPI.sync method, model, options

  onCreate: ->
    @trigger "create", @, @id

  path: ->
    if @isNew()
      "javascript:void(0)"
    else
      "#{Coreon.application.repository().path()}/concepts/#{@id}"

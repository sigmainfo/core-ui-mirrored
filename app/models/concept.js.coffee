#= require environment
#= require modules/helpers
#= require modules/accumulation
#= require modules/embeds_many
#= require modules/remote_validation
#= require models/term

class Coreon.Models.Concept extends Backbone.Model

  Coreon.Modules.extend @, Coreon.Modules.Accumulation
  Coreon.Modules.extend @, Coreon.Modules.EmbedsMany

  Coreon.Modules.include @, Coreon.Modules.RemoteValidation

  @embedsMany "properties"
  @embedsMany "terms", model: Coreon.Models.Term

  urlRoot: "concepts"

  defaults: ->
    properties: []
    terms: []
    super_concept_ids: []
    sub_concept_ids: []
    label: ""
    hit: null

  initialize: (attrs, options) ->
    @set "label", @_label(), silent: true
    @on "change:#{@idAttribute} change:terms change:properties", @_updateLabel, @
    @_updateHit()
    if Coreon.application?.hits?
      @listenTo Coreon.application.hits, "reset add remove", @_updateHit
    @remoteValidationOn()
    @once "sync", @syncMessage, @ if @isNew()

  toJSON: (options) ->
    serialized = {}
    for key, value of @attributes when key not in ["hit", "label"]
      serialized[key] = value
    concept: serialized

  info: ->
    info = id: @id
    defaults = ( key for key, value of @defaults() )
    defaults.push @idAttribute
    for key, value of @attributes when key not in defaults
      info[key] = value
    info

  _updateLabel: ->
    @set "label", @_label()

  _updateHit: ->
    @set "hit", Coreon.application?.hits.findByResult(@)

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
      if term.lang.match /^en/i
        label = term.value
        break
    label ?= terms[0]?.value
    label

  sync: (method, model, options = {}) ->
    Coreon.application.sync method, model, options

  syncMessage: ->
    @message I18n.t("concept.sync.create", label: @get "label"), type: "info"

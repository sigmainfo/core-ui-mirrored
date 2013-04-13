#= require environment
#= require modules/accumulation
#= require collections/terms

class Coreon.Models.Concept extends Backbone.Model

  _(@).extend Coreon.Modules.Accumulation

  urlRoot: "concepts"

  defaults: ->
    properties: []
    super_concept_ids: []
    sub_concept_ids: []
    label: ""
    hit: null
    terms: new Coreon.Collections.Terms

  initialize: (attrs, options) ->
    @set "label", @_label(), silent: true
    @on "change:#{@idAttribute} change:terms change:properties", @_updateLabel, @
    @_updateHit()
    if Coreon.application?.hits?
      @listenTo Coreon.application.hits, "reset add remove", @_updateHit

  set: (key, val, options) ->
    terms = if key == "terms" then val else key.terms
    return super if not terms
    if not terms.models
      if key == "terms"
        return @get("terms").set terms, options
      else if @has "terms"
        @get("terms").set terms, options
        delete key.terms
        return super key, val, options
      else
        key.terms = new Coreon.Collections.Terms terms
    @stopListening @get("terms") if @has "terms"
    @listenTo @get("terms"), 'all', @_processTermsEvent if super

  addTerm: ->
    @get("terms").push new Coreon.Models.Term

  addProperty: ->
    @get("properties").push
      key: ""
      value: ""
      lang: ""
    @trigger("add:properties")

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

  _processTermsEvent: (e, a, x, z) ->
    if e is "add"
      @trigger 'add:terms'
      @trigger 'change:terms'
    else if e is "change"
      @trigger 'change:terms'
    else if e is "remove"
      @trigger 'remove:terms'
      @trigger 'change:terms'
      
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
    label = null
    for term in @get("terms")?.models
      if term.get("lang").match /^en/i
        label = term.get("value")
        break
    label ?= @get("terms")?.at(0)?.get("value")
    label

  sync: (method, model, options = {}) ->
    Coreon.application.sync method, model, options

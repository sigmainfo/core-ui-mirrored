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
#= require modules/path
#= require modules/core_api
#= require modules/collation
#= require collections/hits
#= require collections/concepts

class Coreon.Models.Concept extends Backbone.Model

  Coreon.Modules.extend @, Coreon.Modules.Accumulation

  @collection = ->
    @_collection ||= new Coreon.Collections.Concepts

  @roots = ->
    graphUri = Coreon.application.graphUri().replace /\/$/, ''
    url = "#{graphUri}#{@::urlRoot}/roots"
    Coreon.Modules.CoreAPI.sync 'read', @collection(), url: url

  Coreon.Modules.extend @, Coreon.Modules.EmbedsMany

  @embedsMany "properties", model: Coreon.Models.Property
  Coreon.Modules.include @, Coreon.Modules.Properties

  @embedsMany "terms", collection: Coreon.Collections.Terms

  Coreon.Modules.include @, Coreon.Modules.SystemInfo
  Coreon.Modules.include @, Coreon.Modules.RemoteValidation
  Coreon.Modules.include @, Coreon.Modules.PersistedAttributes
  Coreon.Modules.include @, Coreon.Modules.Path

  urlRoot  : '/concepts'
  pathName : 'concepts'

  defaults: ->
    properties: []
    terms: []
    superconcept_ids: []
    subconcept_ids: []
    label: ''
    hit: null

  initialize: (attrs, options = {}) ->

    @app = options.app or Coreon.application

    @stopListening()

    @updateLabel @, silent: yes
    @listenTo @
            , 'change:id change:terms change:properties'
            , @updateLabel
    @listenTo @app
            , 'change:langs'
            , @updateLabel

    @_updateHit()
    @listenTo Coreon.Collections.Hits.collection()
            , "reset add remove"
            , @_updateHit
    @remoteValidationOn()
    @once "sync", @syncMessage, @ if @isNew()
    @persistedAttributesOn()

  termsByLang: ->
    @terms().reduce (grouped, term) ->
      lang = term.get('lang').toLowerCase()
      grouped[lang] ?= []
      grouped[lang].push term
      grouped
    , {}

  toJSON: (options) ->
    serialized = {}
    for key, value of @attributes when key not in ["hit", "label"]
      serialized[key] = value
    concept: serialized

  updateLabel: (model, options) ->
    label = if @isNew()
      I18n.t 'concept.new_concept'
    else
      @propLabel() or @termLabel() or @id

    @set 'label', label, options

  termLabel: ->
    if term = @preferredTerm()
      term.get('value')
    else
      null

  normalized = (lang = '') ->
    lang[0..1].toLowerCase()

  preferredTerm: ->
    terms = @terms()
    term = null
    langs = @app.get('langs').concat 'en'
    for lang in langs
      term = terms.find (term) ->
        normalized(term.get 'lang') is normalized(lang)
      break if term?
    term ?= terms.first()
    term

  propLabel: ->
    properties = @propertiesByKey()
    if labels = _(properties).findWhere(key: 'label')
      labels.properties[0].get 'value'
    else
      null

  _updateHit: ->
    @set "hit", Coreon.Collections.Hits.collection().findByResult(@)

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

  broader: ->
    concepts = @get('superconcept_ids').map (id) ->
      Coreon.Models.Concept.find id

  definition: ->
    properties = @propertiesByKey()
    if definitions = _(properties).findWhere(key: 'definition')
      definitions.properties[0].get 'value'
    else
      null


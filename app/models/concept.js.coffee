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
#= require formatters/properties_formatter

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
  @embedsMany "terms", collection: Coreon.Collections.Terms

  Coreon.Modules.include @, Coreon.Modules.SystemInfo
  Coreon.Modules.include @, Coreon.Modules.PropertiesByKey
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
    label: ""
    hit: null

  initialize: (attrs, options) ->
    @set "label", @_label(), silent: true
    @on "change:#{@idAttribute} change:terms change:properties"
      , @_updateLabel
      , @
    if Coreon.application?.repositorySettings()
      @listenTo Coreon.application.repositorySettings()
              , 'change:sourceLanguage change:targetLanguage'
              , @_updateLabel
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
    @propertiesByKeyAndLang()['label']?[0]?.get('value')

  _termLabel: ->
    terms = @get "terms"

    if settings = Coreon.application?.repositorySettings()
      sourceLang = settings.get('sourceLanguage')
      targetLang = settings.get('targetLanguage')
      locale = settings.get('locale')

    locale ||= 'en'

    langRegexp = new RegExp("^#{sourceLang}", 'i') if sourceLang
    fallbackLangRegexp = new RegExp("^#{targetLang}", 'i') if targetLang
    localeRegexp = new RegExp("^#{locale}", 'i')

    for term in terms
      if sourceLang and !!term.lang?.match langRegexp
        label = term.value
        break
      if targetLang and not fallbackLabel? and !!term.lang?.match fallbackLangRegexp
        fallbackLabel = term.value
      if not localeLabel? and !!term.lang?.match localeRegexp
        localeLabel = term.value

    label ?= fallbackLabel || localeLabel || terms[0]?.value
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

  broader: ->
    concepts = @get('superconcept_ids').map (id) ->
      Coreon.Models.Concept.find id

  definition: ->
    @propertiesByKeyAndLang().definition?[0].get('value') or null

  propertiesWithDefaults: (options) ->
    formatter = new Coreon.Formatters.PropertiesFormatter(
      Coreon.Models.RepositorySettings.propertiesFor('concept'),
      @properties().map((p) -> p),
      @errors()?.nested_errors_on_properties,
      options
    )
    formatter.all()
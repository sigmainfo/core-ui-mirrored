#= require environment
#= require modules/helpers
#= require modules/embeds_many
#= require models/property
#= require modules/system_info
#= require modules/properties_by_key
#= require modules/remote_validation
#= require modules/persisted_attributes
#= require modules/core_api
#= require modules/path
#= require formatters/properties_formatter

class Coreon.Models.Term extends Backbone.Model

  Coreon.Modules.extend @, Coreon.Modules.EmbedsMany

  @embedsMany "properties", model: Coreon.Models.Property

  Coreon.Modules.include @, Coreon.Modules.SystemInfo
  Coreon.Modules.include @, Coreon.Modules.PropertiesByKey
  Coreon.Modules.include @, Coreon.Modules.RemoteValidation
  Coreon.Modules.include @, Coreon.Modules.PersistedAttributes

  defaults: ->
    properties: []
    value: ""
    lang: ""
    concept_id: ""

  urlRoot: ->
    "/concepts/#{@get "concept_id"}/terms"

  initialize: ->
    @remoteValidationOn()
    @_persistedAttributes = {}
    @_persistedAttributes[attr] = value for attr, value of @attributes
    @persistedAttributesOn()

  toJSON: ->
    json = {}
    #json[attr] = value for attr, value of super when attr isnt "concept_id"
    json[attr] = value for attr, value of super
    term: json

  save: ->
    super

  sync: (method, model, options = {}) ->
    @once "sync", @onCreate, @ if method is "create"
    Coreon.Modules.CoreAPI.sync method, model, options

  onCreate: ->
    @trigger "create", @, @.id

  # use fake concept to avoid recursion in dependency tree
  class FakeConcept extends Backbone.Model
    Coreon.Modules.include @, Coreon.Modules.Path
    pathName: 'concepts'

  conceptPath: ->
    new FakeConcept( id: @get 'concept_id' ).path()

  propertiesWithDefaults: (options) ->
    formatter = new Coreon.Formatters.PropertiesFormatter(
      Coreon.Models.RepositorySettings.propertiesFor('term'),
      @properties().map((p) -> p),
      @errors()?.nested_errors_on_properties,
      options
    )
    formatter.all()

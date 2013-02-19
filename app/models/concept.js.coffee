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
  
  terms: null

  initialize: (attrs, options) ->

    # Terms als Collection nicht als Array reingeben.
    console.log( "initialize() - TODO: Terms als Collection" )
    
    @terms = new Coreon.Collections.Terms
    @listenTo @terms, 'all', @_processTermsEvent
    @terms.reset options.terms if options?.terms?
    @set "label", @_label(), silent: true
    @on "change:terms change:properties", @_updateLabel, @
 
    #  toJSON: (options) ->
    #{concept: _.clone(this.attributes)}

  info: ->
    info = id: @id
    defaults = ( key for key, value of @defaults() )
    defaults.push @idAttribute
    for key, value of @attributes when key not in defaults
      info[key] = value
    info

  _processTermsEvent: (e) ->
    @_updateLabel()

  hit: ->
    Coreon.application.hits.get(@id)?

  _updateLabel: ->
    @set "label", @_label()

  _label: ->
    _.escape( @_propLabel() or @_termLabel() or @id )

  _propLabel: ->
    _(@get "properties")?.find( (prop) -> prop.key is "label" )?.value

  _termLabel: ->
    label = null
    @terms.each (term) ->
      if term.get("lang").match /^en/i
        label = term.get("value")
        #return
    label ||= @terms.at(0)?.get("value")
    label

  sync: (method, model, options = {}) ->
    Coreon.application.sync method, model, options

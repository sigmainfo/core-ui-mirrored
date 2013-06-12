#= require environment

updatePersistedAttributes = ->
  attrs = {}
  attrs[key] = value for key, value of @attributes
  @_persistedAttributes = attrs

Coreon.Modules.PersistedAttributes =

  persistedAttributesOn: ->
    @on "sync", updatePersistedAttributes, @

  persistedAttributesOff: ->
    delete @_persistedAttributes
    @off "sync", updatePersistedAttributes, @

  persistedAttributes: ->
    @_persistedAttributes or {}

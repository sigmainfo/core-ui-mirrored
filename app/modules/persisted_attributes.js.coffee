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
    @_persistedAttributes ?= {}

  isPersisted: (attr) ->
    @persistedAttributes().hasOwnProperty(attr) and
    @persistedAttributes()[attr] is @get(attr) 

  revert: (options = {}) ->
    opts = {}
    opts[key] = value for key, value of options
    opts.silent = on
    persisted = @persistedAttributes()
    for attr of @attributes when not @isPersisted attr
      if persisted.hasOwnProperty attr
        @set attr, persisted[attr], opts
      else
        @unset attr, opts
      @trigger "change:#{attr}", @, persisted[attr], options unless options.silent?
    @trigger "change", @, options unless options.silent?
    @

#= require environment

copyTo = (errors, other) ->
  if other
    for attr, attrErrors of other
      errors[attr] ?= []
      for error in attrErrors
        errors[attr].push error unless error in errors[attr]

onError = (model, xhr, options) ->
  response = JSON.parse(xhr.responseText).errors
  @remoteError = {}
  nested = {}
  for attr, attrErrors of response
    if attr.indexOf("nested_errors_on") is 0
      nested[attr[17..]] = attrErrors
    else
      @remoteError[attr] = attrErrors
  for attr, attrErrors of nested
    @remoteError[attr] = attrErrors

onSync = ->
  @remoteError = null

Coreon.Modules.RemoteValidation =
  
  remoteError: null

  remoteValidationOn: ->
    @on "error", onError, @
    @on "sync", onSync, @

  errors: ->
    if @remoteError? and @validationError?
      errors = {}
      copyTo errors, @remoteError
      copyTo errors, @validationError
      errors
    else
      @remoteError or @validationError

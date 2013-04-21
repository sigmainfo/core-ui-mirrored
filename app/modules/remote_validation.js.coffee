#= require environment

copyTo = (errors, other) ->
  if other
    for attr, attrErrors of other
      errors[attr] ?= []
      unless attr.indexOf("nested_errors_on_") is 0
        for error in attrErrors
          errors[attr].push error unless error in errors[attr]
      else
        for error, index in attrErrors
          errors[attr][index] ?= {}
          copyTo errors[attr][index], error

onError = (model, xhr, options) ->
  response = JSON.parse(xhr.responseText).errors
  remoteError = {}
  hasErrors = no
  for attr, attrErrors of response
    unless attrErrors.length is 0
      hasErrors = true
      remoteError[attr] = attrErrors 
  @remoteError = if hasErrors then remoteError else null

onSync = ->
  @remoteError = null

Coreon.Modules.RemoteValidation =
  
  remoteError: null

  remoteValidationOn: ->
    @on "error", onError, @
    @on "sync", onSync, @

  remoteValidationOff: ->
    @off "error", onError, @
    @off "sync", onSync, @

  errors: ->
    if @remoteError? and @validationError?
      errors = {}
      copyTo errors, @remoteError
      copyTo errors, @validationError
      errors
    else
      @remoteError or @validationError

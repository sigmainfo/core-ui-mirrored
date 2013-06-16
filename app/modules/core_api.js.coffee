#= require environment
#= require modules/helpers

connections = 0

auth = (deferred, method, model, options = {}) ->
  session = Coreon.application.session

  request = session.sync(method, model, options)

  Coreon.Modules.CoreAPI.trigger "start" if connections is 0
  connections += 1

  request.always ->
    connections -= 1
    #if connections is 0 and request.status < 400  # TODO: is this working?
    Coreon.Modules.CoreAPI.trigger "stop"

  request.done (data, status, request) ->
    deferred.resolveWith model, [data, request]

  request.fail (request, status, error) ->
    data =
      try
        JSON.parse request.responseText
      catch exception
        {}
    deferred.rejectWith model, [data, request]
    Coreon.Modules.CoreAPI.trigger "error", request.status, error, data, request
    Coreon.Modules.CoreAPI.trigger "error:#{request.status}", error, data, request

  request


ajax = (deferred, method, model, options) ->
  session = Coreon.application.session
  options.headers["X-Core-Session"] = session.getToken()

  request = Backbone.sync(method, model, options)
  connections += 1
  Coreon.Modules.CoreAPI.trigger "request", method, options.url, request

  request.always ->
    connections -= 1
    if connections is 0 and request.status < 400
      Coreon.Modules.CoreAPI.trigger "stop"

  request.done (data, status, request) ->
    deferred.resolveWith model, [data, request]

  request.fail (request, status, error) ->
    data =
      try
        JSON.parse request.responseText
      catch exception
        {}
    if request.status is 401
      session.unsetToken()
      session.once "change:token", ->
        ajax deferred, method, model, options
    else
      deferred.rejectWith model, [data, request]
      Coreon.Modules.CoreAPI.trigger "error", request.status, error, data, request
      Coreon.Modules.CoreAPI.trigger "error:#{request.status}", error, data, request

  request

Coreon.Modules.CoreAPI =

  session: (token) ->
    null

  # login: (email, password)->
  #   session = Coreon.application.session
  #   deferred = $.Deferred()
  #   options =
  #     email:email
  #     password:password
  #   auth deferred, "create", session, options
  #   deferred.promise()


  # logout: ->
  #   session = Coreon.application.session
  #   deferred = $.Deferred()
  #   auth deferred, "delete", session
  #   deferred.promise()


  # reauth: (password)->
  #   session = Coreon.application.session
  #   deferred = $.Deferred()
  #   options =
  #     password:password
  #   auth deferred, "update", session, options
  #   deferred.promise()


  # getSession: ->
  #   session = Coreon.application.session
  #   deferred = $.Deferred()
  #   auth deferred, "read", session
  #   deferred.promise()


  sync: (method, model, options = {}) ->
    deferred = $.Deferred()

    root = Coreon.application.session.get "repo_root"
    root = root[..-2] if root.charAt(root.length - 1) is "/"
    path = model.url()
    path = path[1..] if path.charAt(0) is "/"
    options.url ?= "#{root}/#{path}"
    options.headers ?= {}

    Coreon.Modules.CoreAPI.trigger "start" if connections is 0
    ajax deferred, method, model, options

    deferred.promise()

Coreon.Modules.extend Coreon.Modules.CoreAPI, Backbone.Events

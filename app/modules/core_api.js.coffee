#= require environment
#= require modules/helpers

connections = 0

ajax = (deferred, method, model, options) ->
  session = Coreon.application.get "session"
  options.headers["X-Core-Session"] = session.get "auth_token"
  request = Backbone.sync(method, model, options)
  connections += 1
  Coreon.Modules.CoreAPI.trigger "request", method, options.url, request

  request.always ->
    connections -= 1
    if connections is 0 and request.status isnt 403
      Coreon.Modules.CoreAPI.trigger "stop" 

  request.done (data, status, request) ->
    deferred.resolveWith model, [data, request]

  request.fail (request, status, error) ->
    data =
      try
        JSON.parse request.responseText
      catch exception
        {}
    if request.status is 403
      session.unset "auth_token"
      session.once "change:auth_token", ->
        ajax deferred, method, model, options
    else
      deferred.rejectWith model, [data, request]
      Coreon.Modules.CoreAPI.trigger "error", request.status, error, data, request
      Coreon.Modules.CoreAPI.trigger "error:#{request.status}", error, data, request

  request 

Coreon.Modules.CoreAPI =

  sync: (method, model, options = {}) ->
    deferred = $.Deferred()

    root = Coreon.application.graphUri() or throw new Error "No graph URI specified"
    root = root[..-2] if root.charAt(root.length - 1) is "/"
    path = model.url()
    path = path[1..] if path.charAt(0) is "/"
    options.url ?= "#{root}/#{path}"
    options.headers ?= {}

    Coreon.Modules.CoreAPI.trigger "start" if connections is 0
    ajax deferred, method, model, options

    deferred.promise()

Coreon.Modules.extend Coreon.Modules.CoreAPI, Backbone.Events

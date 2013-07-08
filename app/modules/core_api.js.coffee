#= require environment
#= require modules/helpers

BATCH_DELAY = 250

connections = 0
batches = {}
timers = []

urlFor = (path) ->
  root = Coreon.application.graphUri() or throw new Error "No graph URI specified"
  root = root[..-2] if root.charAt(root.length - 1) is "/"
  path = path[1..] if path.charAt(0) is "/"
  [root, path].join "/"


ajax = (deferred, method, model, options) ->
  session = Coreon.application.get "session"
  options.headers ?= {}
  options.headers["X-Core-Session"] = session.get "auth_token"

  options.url ?= urlFor model.url()

  request = Backbone.sync(method, model, options)
  Coreon.Modules.CoreAPI.trigger "start" if connections is 0
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

batch = (deferred, method, model, options) ->
  path = model.batchUrl method
  param = model.batchParam method
  name = "#{path} #{param}"
  unless batches[name]?
    batches[name] = []

    opts = {}
    opts[key] = value for key, value of options

    ajax arguments...
    
    opts.type ?= "POST"
    opts.url  ?= urlFor path
    unless options.data?
      opts.data = {}
      opts.data[param] = batches[name]

    timers.push _.delay batchAjax, BATCH_DELAY, name, deferred, method, model, opts
  else
    data = model.batchData method
    batches[name].push data

batchAjax = (name, deferred, method, model, options) ->
  ajax deferred, method, model, options if batches[name].length > 0
  delete batches[name]

Coreon.Modules.CoreAPI =

  sync: (method, model, options = {}) ->

    if method is "abort"
      batches = {}
      clearTimeout timer for timer in timers
      timers = []
      return

    deferred = $.Deferred()

    unless options.batch?
      ajax deferred, method, model, options
    else
      batch deferred, method, model, options
      
    deferred.promise()

Coreon.Modules.extend Coreon.Modules.CoreAPI, Backbone.Events

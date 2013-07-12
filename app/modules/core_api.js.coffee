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
  url = if options.url?
    options.url
  else
    root = urlFor _.result model, "urlRoot"
    root = root[..-2] if root.charAt(root.length - 1) is "/"
    url = "#{root}/fetch"

  opts = {}
  opts[key] = value for key, value of options

  if batches[url]?
    deferred.model = model
    deferred.options = opts
    batches[url].push deferred
  else
    batches[url] = []
    ajax arguments...
    timers.push _.delay batchAjax, BATCH_DELAY, url, opts

batchAjax = (url, options) ->
  
  return if batches[url].length is 0

  request = $.Deferred()

  options.url = url
  options.type ?= "POST"
  options.data ?= ids: (deferred.model.id for deferred in batches[url])
  
  delete options.success
  delete options.error

  ajax request, "read", null, options 

  request.done (data, request) ->
    if batches[url]?
      for deferred in batches[url]
        for attrs in data when attrs._id is deferred.model.id
          current = attrs
          break
        if success = deferred.options.success
          success deferred.model, current, deferred.options
        deferred.resolveWith deferred.model, [current, request] 
      delete batches[url]

  request.fail (data, request) ->
    if batches[url]?
      for deferred in batches[url]
        if error = deferred.options.error
          error deferred.model, data, deferred.options
        deferred.rejectWith deferred.model, [data, request]
      delete batches[url]

reset = ->
  clearTimeout timer for timer in timers
  timers = []
  for url, deferreds of batches 
    deferred.reject() for deferred in deferreds
  batches = {}

Coreon.Modules.CoreAPI =

  sync: (method, model, options = {}) ->

    if method is "abort"
      reset()
      return

    deferred = $.Deferred()

    if method is "read" and options.batch
      batch deferred, method, model, options
    else
      ajax deferred, method, model, options
      
    deferred.promise()

Coreon.Modules.extend Coreon.Modules.CoreAPI, Backbone.Events

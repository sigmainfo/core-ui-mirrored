#= require environment
#= require modules/helpers

BATCH_LIMIT = 50
STRIP_SLASHES = /^\/?(.*?)\/?$/

xhrs = []
queues = {}

urlFor = (path) ->
  root = Coreon.application.graphUri() or throw new Error "No graph URI specified"
  (segment.replace STRIP_SLASHES, "$1" for segment in [root, arguments...]).join "/"


ajax = (deferred, method, model, options) ->
  session = Coreon.application.get "session"
  options.headers ?= {}
  options.headers["X-Core-Session"] = session.get "auth_token"

  options.url ?= urlFor model.url()

  request = Backbone.sync(method, model, options)
  Coreon.Modules.CoreAPI.trigger "start" if xhrs.length is 0
  xhrs.push request
  Coreon.Modules.CoreAPI.trigger "request", method, options.url, request

  request.always ->
    xhrs = (xhr for xhr in xhrs when xhr isnt request)
    if xhrs.length is 0 and request.status isnt 403
      Coreon.Modules.CoreAPI.trigger "stop" 

  request.done (data, status, request) ->
    deferred.resolveWith model, [data, request]

  request.fail (xhr, status, error) ->
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

  url = options.url or urlFor _.result(model, "urlRoot"), "fetch"
  busy = queues[url]?

  queues[url] ?= []
  queues[url].push
    model: model
    deferred: deferred
    success: options.success
    error: options.error

  next url, options unless busy

next = (url, options) ->

  max = options.batch_limit or BATCH_LIMIT
  chunk = queues[url].splice 0, max

  opts = {}
  for key, value of options when key not in ["error", "success"] 
    opts[key] = value
  
  if chunk.length is 0
    delete queues[url]
  else
    if chunk.length is 1
      queued = chunk[0]
      model        = queued.model
      deferred     = queued.deferred
      opts.success = queued.success
      opts.error   = queued.error
    else
      model = trigger: (event, args...) ->
        for queued in chunk
          model = queued.model
          model.trigger event, model, args[1..]...

      deferred = $.Deferred()
        .done (data = [], request, args...) ->
          for queued in chunk
            model = queued.model
            deferred = queued.deferred
            for attrs in data when attrs[model.idAttribute] is model.id
              queued.success attrs, "success", request if queued.success?
              deferred.resolveWith model, [attrs, request, args...]
              break
        .fail (data, request, args...)->
          for queued in chunk
            model = queued.model
            deferred = queued.deferred
            queued.error request, "error", request.statusText if queued.error?
            deferred.rejectWith model, arguments

      opts.data = ids: (queued.model.id for queued in chunk)
      opts.type = "POST"
      opts.url = url

    ajax(deferred, "read", model, opts).always ->
      next url, options

reset = ->
  xhrs[0].abort() while xhrs.length
  queues = {}

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

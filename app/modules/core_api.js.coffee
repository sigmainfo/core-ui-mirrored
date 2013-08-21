#= require environment
#= require modules/helpers

BATCH_DELAY = 200

xhrs = []

batches = {}
timers = []

_dummy = trigger: ->

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
  Coreon.Modules.CoreAPI.trigger "start" if xhrs.length is 0
  xhrs.push request
  Coreon.Modules.CoreAPI.trigger "request", method, options.url, request

  request.always ->
    xhrs = (xhr for xhr in xhrs when xhr isnt request)
    if xhrs.length is 0 and request.status isnt 403
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
    model.trigger "request", model, deferred.promise(), opts
  else
    ajax arguments...
    batches[url] = []
    timers.push _.delay batchAjax, BATCH_DELAY, url, opts

batchAjax = (url, options) ->

  if currentBatch = batches[url]
    
   if currentBatch.length > 0

      request = $.Deferred()

      delete options.success
      delete options.error

      options.url = url
      options.type ?= "POST"
      options.data ?= ids: (deferred.model.id for deferred in currentBatch)

      ajax request, "read", _dummy, options 

      request.done (data, request) ->
        if currentBatch?
          for deferred in currentBatch
            for attrs in data when attrs._id is deferred.model.id
              current = attrs
              break
            if success = deferred.options.success
              success current, "success", request
            deferred.resolveWith deferred.model, [current, request] 

      request.fail (data, request) ->
        if currentBatch?
          for deferred in currentBatch
            if error = deferred.options.error
              error request, "error", request.statusText
            deferred.rejectWith deferred.model, [data, request]

    delete batches[url]

reset = ->
  xhrs[0].abort() while xhrs.length
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

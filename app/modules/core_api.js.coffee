#= require environment
#= require modules/helpers

connections = 0

Coreon.Modules.CoreAPI =

  sync: (method, model, options = {}) ->
    request = $.Deferred()
    session = Coreon.application.session

    options.headers ?= {}
    options.headers["X-Core-Session"] = session.get "token"
    
    root = session.get "repository_root"
    root = root[..-2] if root.charAt(root.length - 1) is "/"
    path = model.url()
    path = path[1..] if path.charAt(0) is "/"
    options.url ?= "#{root}/#{path}"

    xhr = Backbone.sync(method, model, options)
    Coreon.Modules.CoreAPI.trigger "request", method, options.url, xhr

    Coreon.Modules.CoreAPI.trigger "start" if connections is 0
    connections += 1
    xhr.always ->
      connections -= 1
      Coreon.Modules.CoreAPI.trigger "stop" if connections is 0

    xhr.done (data, status, xhr) ->
      request.resolveWith model, [data, xhr]

    xhr.fail (xhr, status, error) ->
      data =
        try
          JSON.parse xhr.responseText
        catch exception
          {}
      request.rejectWith model, [data, xhr]
      Coreon.Modules.CoreAPI.trigger "error", xhr.status, error, data, xhr
      Coreon.Modules.CoreAPI.trigger "error:#{xhr.status}", error, data, xhr

    request.promise()

Coreon.Modules.extend Coreon.Modules.CoreAPI, Backbone.Events

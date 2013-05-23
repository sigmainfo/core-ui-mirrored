#= require environment

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
    options.url = "#{root}/#{path}"

    xhr = Backbone.sync(method, model, options)

    xhr.done (data, status, xhr) ->
      request.resolveWith model, [data, xhr]

    xhr.fail (xhr, status, error) =>
      data =
        try
          JSON.parse xhr.responseText
        catch exception
          {}
      # @trigger "error", xhr.status, error, data, xhr
      request.rejectWith model, [data, xhr]

    request.promise()

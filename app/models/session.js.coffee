#= require environment

class Coreon.Models.Session extends Backbone.Model
  
  @auth_root = null

  @load = () ->
    request = $.Deferred()
    if token = localStorage.getItem "coreon-session"
      session = new @ auth_token: token
      session.fetch()
        .done( -> request.resolve session )
        .fail( -> request.resolve null )
    else
      request.resolve null
    request.promise()

  @authenticate = (email, password) ->
    request = $.Deferred()
    session = new @
    session.save({}, data: $.param email: email, password: password)
      .done( -> request.resolve session )
      .fail( -> request.resolve null )
    request.promise()

  idAttribute: "auth_token"

  urlRoot: -> "#{Coreon.Models.Session.auth_root.replace /\/$/, ''}/login"

  destroy: ->
    super
    localStorage.removeItem "coreon-session"

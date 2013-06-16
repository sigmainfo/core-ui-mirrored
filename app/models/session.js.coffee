#= require environment

class Coreon.Models.Session extends Backbone.Model

  @load = (root) ->
    request = $.Deferred()
    if token = localStorage.getItem "coreon-session"
      session = new @ auth_token: token, auth_root: root
      session.fetch()
        .fail(-> request.resolve null)
        .done(-> request.resolve session)
    else
      request.resolve null
    request.promise()

  idAttribute: "auth_token"

  urlRoot: -> "#{@get('auth_root').replace /\/$/, ''}/login"

  destroy: ->
    super
    localStorage.removeItem "coreon-session"

  # defaults:
  #   active: false
  #   email: ""
  #   name: ""
  #   token: null
  #   auth_root: "/api/auth/"
  #   graph_root: "/api/graph/"

  # options:
  #   sessionId: "coreon-session"

  # initialize: ->
  #   @notifications = new Coreon.Collections.Notifications
  #   @connections = new Coreon.Collections.Connections
  #   @connections.session = @
  #   @ability = new Coreon.Models.Ability

  #   @on "change:token", @_updateActiveState, @
  #   @_updateActiveState()

  #   @connections.on "error:403", @onUnauthorized
  #   
  # activate: (email, password) ->
  #   @set "email", email
  #   @requestSession password, @onActivated

  # onActivated: (data) =>
  #   @save
  #     name: data.user.name
  #     token: data.auth_token
  #   @trigger "activated"
  #   @notifications.reset()
  #   @message I18n.t("notifications.account.login", name: @get "name")

  # reactivate: (password) ->
  #   @requestSession password, @onReactivated

  # onReactivated: (data) =>
  #   @save token: data.auth_token
  #   @trigger "reactivated"

  # requestSession: (password, done) ->
  #   email = @get("email")
  #   options =
  #     url: @get("auth_root") + "login"
  #     type: "POST"
  #     dataType: "json"
  #     data:
  #       email: email
  #       password: password
  #   
  #   @connections.add
  #     model: @
  #     options: options
  #     xhr: $.ajax(options).done done


  # onUnauthorized: =>
  #   @unset "token"
  #   @trigger "unauthorized"

  # deactivate: ->
  #   @set "active", false
  #   @sync "delete", @
  #   @trigger "deactivated"
  #   @notifications.reset()
  #   @message I18n.t("notifications.account.logout")

  # sync: (action, model, options)->
  #   fields = ["token", "email", "name"]
  #   switch action
  #     when "create", "update"
  #       data = {}
  #       for key, value of @attributes when key not in [ "active", "graph_root", "auth_root" ] 
  #         data[key] = value
  #       localStorage.setItem @options.sessionId, JSON.stringify data
  #     when "read"
  #       @set JSON.parse localStorage.getItem @options.sessionId 
  #     when "delete"
  #       localStorage.removeItem @options.sessionId

  # destroy: ->
  #   @notifications.destroy()
  #   @connections.destroy()
  #   @sync "delete", @

  # _updateActiveState: ->
  #   @set "active", @has("token")

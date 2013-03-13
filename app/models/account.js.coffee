#= require environment
#= require collections/notifications
#= require collections/connections

class Coreon.Models.Account extends Backbone.Model

  defaults:
    active: false
    name: ""
    auth_root: "/api/auth/"
    graph_root: "/api/graph/"

  initialize: ->
    @notifications = new Coreon.Collections.Notifications
    @connections = new Coreon.Collections.Connections
    @connections.account = @

    @connections.on "error:403", @onUnauthorized
    
  activate: (login, password) ->
    @set "login", login
    @requestSession password, @onActivated

  onActivated: (data) =>
    @set "active", true
    @save
      name: data.user.name
      session: data.auth_token
    @trigger "activated"
    @notifications.reset()
    @message I18n.t("notifications.account.login", name: @get "name")

  reactivate: (password) ->
    @requestSession password, @onReactivated

  onReactivated: (data) =>
    @save session: data.auth_token
    @trigger "reactivated"

  requestSession: (password, done) ->
    login = @get("login")
    options =
      url: @get("auth_root") + "login"
      type: "POST"
      dataType: "json"
      data:
        login: login
        password: password
    
    @connections.add
      model: @
      options: options
      xhr: $.ajax(options).done done


  onUnauthorized: =>
    @unset "session"
    @trigger "unauthorized"

  deactivate: ->
    @set "active", false
    @sync "delete", @
    @trigger "deactivated"
    @notifications.reset()
    @message I18n.t("notifications.account.logout")

  sync: (action, model, options)->
    fields = ["session", "login", "name"]
    switch action
      when "create", "update"
        localStorage.setItem field, @get(field) for field in fields
      when "read"
        @set field, localStorage.getItem(field) for field in fields
        @set "active", @has("session")
      when "delete"
        localStorage.removeItem field for field in fields

  destroy: ->
    @notifications.destroy()
    @connections.destroy()
    @sync "delete", @

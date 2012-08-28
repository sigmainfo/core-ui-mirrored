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

    @connections.on "error:403", @onUnauthorized
    
  activate: (login, password) ->
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
      xhr: $.ajax(options).done @onActivated

  onActivated: (data) =>
    @set "active", true
    @save
      name: data.user.name
      session: data.auth_token
    @trigger "activated"
    @notifications.reset()
    @message I18n.t("notifications.account.login", name: @get "name")

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
    switch action
      when "create", "update"
        localStorage.setItem "session", @get("session")
        localStorage.setItem "name", @get("name")
      when "read"
        @set "session", localStorage.getItem("session")
        @set "name", localStorage.getItem("name")
        @set "active", @has("session")
      when "delete"
        localStorage.removeItem "session"
        localStorage.removeItem "name"

  destroy: ->
    @notifications.destroy()
    @connections.destroy()
    @sync "delete", @

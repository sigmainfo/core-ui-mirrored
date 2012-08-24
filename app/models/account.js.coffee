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
    @set "name", data.user.name
    @trigger "activated"
    @notifications.reset()
    @message I18n.t("notifications.account.login", name: @get "name")

  deactivate: ->
    @set "active", false
    @set "name", ""
    @trigger "deactivated"
    @notifications.reset()
    @message I18n.t("notifications.account.logout") 

  destroy: ->
    @notifications.destroy()
    @connections.destroy()

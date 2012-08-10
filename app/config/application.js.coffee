#= require environment
#= require views/application_view
#= require collections/notifications
#= require models/account
#= require routers/account_router

class Coreon.Application

  @defaults:
    el: "#app"
    root: "/"

  init: (options = {}) ->
    @options = _.defaults options, @constructor.defaults

    @notifications = new Coreon.Collections.Notifications
    @account       = new Coreon.Models.Account

    @account.on "logout", @onLogout, @

    @view = new Coreon.Views.ApplicationView
      el: @options.el
      model: @

    @view.render()

    new Coreon.Routers.AccountRouter

    Backbone.history.start
      pushState: true
      root: @options.root
      silent: true

    Backbone.history.navigate "account/login",
      trigger: true

    Coreon.application = @

  notify: (message = "") ->
    @notifications.unshift message: message
    @notifications.at(0)

  onLogout: ->
    @notify I18n.t "notifications.account.logout"

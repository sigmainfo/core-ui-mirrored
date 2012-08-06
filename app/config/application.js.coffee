#= require environment
#= require views/layout/application_view
#= require models/notifications
#= require models/account
#= require routers/account_router

class Coreon.Application

  @defaults:
    el: "#app"
    root: "/"

  init: (options = {}) ->
    @options = _.defaults options, @constructor.defaults

    @notifications = new Coreon.Models.Notifications
    @account       = new Coreon.Models.Account

    @view = new Coreon.Views.Layout.ApplicationView
      el: @options.el
      model: @

    @view.render()

    new Coreon.Routers.AccountRouter

    Backbone.history.start
      pushState: true
      root: @options.root

    Coreon.application = @

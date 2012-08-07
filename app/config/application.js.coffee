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

    @view = new Coreon.Views.ApplicationView
      el: @options.el
      model: @

    @view.render()

    new Coreon.Routers.AccountRouter

    Backbone.history.start
      pushState: true
      root: @options.root

    Coreon.application = @

#= require environment
#= require views/layout/application_view
#= require models/notifications
#= require routers/account_router

class Coreon.Application

  @defaults:
    el: "#app"
    root: "/"

  init: (options = {}) ->
    @options = _.defaults options, @constructor.defaults

    (new Coreon.Views.Layout.ApplicationView el: @options.el).render()

    @notifications = new Coreon.Models.Notifications

    new Coreon.Routers.AccountRouter

    Backbone.history.start
      pushState: true
      root: @options.root

    Coreon.application = @

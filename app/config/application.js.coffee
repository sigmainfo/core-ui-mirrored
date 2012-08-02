#= require environment
#= require views/layout/application_view
#= require routers/account_router

class Coreon.Application
  init: (options = {}) ->
    @options = _.defaults options,
      el: "#app"
    @initViews()
    @initRouters()
    Backbone.history.start
      pushState: true
    @

  initViews: ()->
    layout = new Coreon.Views.Layout.ApplicationView el: @options.el
    layout.render()

  initRouters: ()->
    new Coreon.Routers.AccountRouter


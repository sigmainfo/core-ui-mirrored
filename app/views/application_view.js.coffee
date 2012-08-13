#= require environment
#= require views/tools_view
#= require views/footer_view
#= require views/login_view

class Coreon.Views.ApplicationView extends Backbone.View

  events: "click a[href^='/']": "navigate"

  initialize: ->
    @tools  = new Coreon.Views.ToolsView model: @model
    @footer = new Coreon.Views.FooterView model: @model
    @login  = new Coreon.Views.LoginView model: @model.account

    @model.account.on "login", @loginHandler, @
    @model.account.on "logout", @logoutHandler, @

  destroy: ->
    @model.account.off null, null, @

  render: ->
    @$el.empty()
    @$el.append @tools.render().$el
    if @model.account.idle()
      @logoutHandler()
    else
      @loginHandler()
    @

  navigate: (event) ->
    Backbone.history.navigate $(event.target).attr("href"), trigger: true
    event.preventDefault()

  loginHandler: ->
    return if @model.account.idle()
    @login.remove()
    @login.undelegateEvents()
    @$el.append @footer.render().$el
    @footer.delegateEvents()

  logoutHandler: ->
    @footer.remove()
    @footer.undelegateEvents()
    @$el.append @login.render().$el
    @login.delegateEvents()

#= require environment
#= require templates/application
#= require views/notifications_view
#= require views/widgets_view
#= require views/footer_view
#= require views/login_view

class Coreon.Views.ApplicationView extends Backbone.View

  template: Coreon.Templates["application"]

  events: "click a[href^='/']": "navigate"

  initialize: ->
    @notifications = new Coreon.Views.NotificationsView collection: @model.notifications
    @widgets       = new Coreon.Views.WidgetsView
    @footer        = new Coreon.Views.FooterView model: @model
    @login         = new Coreon.Views.LoginView model: @model.account

    @model.account.on "login", @loginHandler, @
    @model.account.on "logout", @logoutHandler, @

  destroy: ->
    @model.account.off null, null, @

  render: ->
    @$el.html @template()
    @$("#coreon-header").append @notifications.render().$el
    if @model.account.idle() then @renderLogin() else @renderApplication()
    @

  navigate: (event) ->
    Backbone.history.navigate $(event.target).attr("href"), trigger: true
    event.preventDefault()

  loginHandler: ->
    unless @model.account.idle()
      @login.remove()
      @login.undelegateEvents()
      @renderApplication() 
      @footer.delegateEvents()
      @widgets.delegateEvents()

  logoutHandler: ->
    @widgets.remove()
    @widgets.undelegateEvents()
    @footer.remove()
    @footer.undelegateEvents()
    @renderLogin()
    @login.delegateEvents()

  renderApplication: ->
    @$("#coreon-top").append @widgets.render().$el
    @$el.append @footer.render().$el

  renderLogin: ->
    @$el.append @login.render().$el

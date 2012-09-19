#= require environment
#= require views/composite_view
#= require templates/application
#= require views/header_view
#= require views/widgets_view
#= require views/footer_view
#= require views/login_view
#= require views/password_prompt_view

class Coreon.Views.ApplicationView extends Coreon.Views.CompositeView

  template: Coreon.Templates["application"]

  events: "click a[href^='/']": "navigate"

  initialize: ->
    super()
    @header  = new Coreon.Views.HeaderView collection: @model.account.notifications
    @widgets = new Coreon.Views.WidgetsView
    @footer  = new Coreon.Views.FooterView model: @model
    @login   = new Coreon.Views.LoginView model: @model.account
    @prompt  = new Coreon.Views.PasswordPromptView model: @model.account

    @model.account.on "activated", @loginHandler, @
    @model.account.on "deactivated", @logoutHandler, @
    @model.account.on "unauthorized", @onUnauthorized, @
    @model.account.on "reactivated", @onReactivated, @

    @header.on "resize", @onResize, @

  destroy: ->
    @model.account.off null, null, @

  render: ->
    @$el.html @template()
    @$("#coreon-top").prepend @header.render().$el
    if not @model.account.get("active") then @renderLogin() else @renderApplication()
    @

  switch: (screen) ->
    @screen.destroy() if @screen
    @$("#coreon-main").append screen.render().$el
    @screen = screen

  navigate: (event) ->
    Backbone.history.navigate $(event.target).attr("href"), trigger: true
    event.preventDefault()

  loginHandler: ->
    if @model.account.get("active")
      @login.remove()
      @login.undelegateEvents()
      @renderApplication() 
      @footer.delegateEvents()
      @widgets.delegateEvents()

  logoutHandler: ->
    @$("#coreon-main").empty()
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

  onUnauthorized: ->
    @prompt.render().$el.appendTo @$("#coreon-modal")
    @$("#coreon-password-password").focus()

  onReactivated: ->
    @prompt.remove()
    dropped = @model.account.connections.filter (connection) ->
      connection.get("xhr").status == 403 
    connection.resume() for connection in dropped

  onResize: ->
    @login.$el.css "paddingTop": @header.$el.outerHeight()

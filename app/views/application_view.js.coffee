#= require environment
#= require views/composite_view
#= require templates/application/application
#= require views/layout/header_view
#= require views/layout/footer_view
#= require views/widgets/widgets_view
#= require views/account/login_view
#= require views/account/password_prompt_view

class Coreon.Views.ApplicationView extends Coreon.Views.CompositeView

  template: Coreon.Templates["application/application"]

  events: "click a[href^='/']": "navigate"

  initialize: ->
    super
    @subviews  = [
      @header  = new Coreon.Views.Layout.HeaderView collection: @model.notifications
      @footer  = new Coreon.Views.Layout.FooterView model: @model
      @widgets = new Coreon.Views.Widgets.WidgetsView
      @login   = new Coreon.Views.Account.LoginView model: @model
      @prompt  = new Coreon.Views.Account.PasswordPromptView model: @model
    ]

    @model.on "activated"    , @loginHandler   , @
    @model.on "deactivated"  , @logoutHandler  , @
    @model.on "unauthorized" , @onUnauthorized , @
    @model.on "reactivated"  , @onReactivated  , @

    @header.on "resize", @onResize, @

  render: ->
    @$el.html @template()
    @prepend "#coreon-top", @header.render()
    if not @model.get("active") then @renderLogin() else @renderApplication()
    @

  switch: (screen) ->
    @screen.destroy() if @screen
    @append "#coreon-main", screen
    @screen = screen.render()

  navigate: (event) ->
    Backbone.history.navigate $(event.target).attr("href"), trigger: true
    event.preventDefault()

  loginHandler: ->
    if @model.get("active")
      @login.remove()
      @renderApplication() 
      @footer.delegateEvents()
      @widgets.delegateEvents()

  logoutHandler: ->
    @$("#coreon-main").empty()
    @widgets.remove()
    @footer.remove()
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
    dropped = @model.connections.filter (connection) ->
      connection.get("xhr").status == 403 
    connection.resume() for connection in dropped

  onResize: ->
    @login.$el.css "paddingTop": @header.$el.outerHeight()

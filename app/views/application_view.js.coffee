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

    @model.on "activated"    , @activate    , @
    @model.on "deactivated"  , @deactivate  , @
    @model.on "unauthorized" , @reauthorize , @
    @model.on "reactivated"  , @reactivate  , @

    @header.on "resize", @onResize, @

  render: ->
    @$el.html @template()
    @prepend "#coreon-top", @header
    if @model.get "active" then @activate() else @deactivate()
    super

  switch: (screen) ->
    @clearScreen()
    @append "#coreon-main", screen
    @screen = screen.render()

  clearScreen: ->
    @screen.destroy() if @screen

  navigate: (event) ->
    Backbone.history.navigate $(event.target).attr("href"), trigger: true
    event.preventDefault()

  activate: ->
    if @model.get "active"
      @login.remove()
      @append "#coreon-top", @widgets
      @append @footer

  deactivate: ->
    @clearScreen()
    @widgets.remove()
    @footer.remove()
    @append "#coreon-main", @login

  reauthorize: ->
    @append "#coreon-modal", @prompt
    @$("#coreon-password-password").focus()

  reactivate: ->
    @prompt.remove()
    dropped = @model.connections.filter (connection) ->
      connection.get("xhr").status == 403 
    connection.resume() for connection in dropped

  onResize: ->
    @login.$el.css "paddingTop": @header.$el.outerHeight()

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
    @header = new Coreon.Views.Layout.HeaderView
      collection: @model.notifications
    @add @header
    @header.on "resize", @onResize, @

    @model.on "activated"    , @activate    , @
    @model.on "deactivated"  , @deactivate  , @
    @model.on "unauthorized" , @reauthorize , @
    @model.on "reactivated"  , @reactivate  , @

  render: ->
    @$el.html @template()
    @prepend "#coreon-top", @header
    super
    if @model.get "active" then @activate() else @deactivate()
    @

  switch: (screen) ->
    @destroy @screen if @screen
    @screen = screen
    @append "#coreon-main", screen.render()

  navigate: (event) ->
    Backbone.history.navigate $(event.target).attr("href"), trigger: true
    event.preventDefault()

  clear: ->
    subviews = _(@subviews).without @header
    if subviews.length > 0
      @destroy.apply @, _(@subviews).without @header

  activate: ->
    if @model.get "active"
      @clear()
      @widgets = new Coreon.Views.Widgets.WidgetsView
      @append "#coreon-top", @widgets.render()
      @footer = new Coreon.Views.Layout.FooterView
        model: @model
      @append @footer.render()

  deactivate: ->
    @clear()
    @login = new Coreon.Views.Account.LoginView
      model: @model
    @append "#coreon-main", @login.render()

  reauthorize: ->
    @destroy @prompt if @prompt
    @prompt = new Coreon.Views.Account.PasswordPromptView
      model: @model
    @append "#coreon-modal", @prompt.render()
    @$("#coreon-password-password").focus()

  reactivate: ->
    @destroy @prompt if @prompt
    dropped = @model.connections.filter (connection) ->
      connection.get("xhr").status == 403 
    connection.resume() for connection in dropped

  onResize: ->
    @$("#coreon-main").css "paddingTop": @header.$el.outerHeight()

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
      collection: @model.session.notifications
    @add @header
    @header.on "resize", @onResize, @

    @model.session.on "activated"    , @activate    , @
    @model.session.on "deactivated"  , @deactivate  , @
    @model.session.on "unauthorized" , @reauthorize , @
    @model.session.on "reactivated"  , @reactivate  , @

  render: ->
    @$el.html @template()
    @prepend "#coreon-top", @header
    super
    if @model.session.get "active" then @activate() else @deactivate()
    @

  switch: (screen) ->
    @destroy @screen if @screen
    @screen = screen.render()
    @append "#coreon-main", @screen

  navigate: (event) ->
    event.preventDefault()
    Backbone.history.navigate $(event.target).closest("a").attr("href"), trigger: true

  clear: ->
    subviews = (view for view in @subviews when view isnt @header)
    @destroy.apply @, subviews if subviews.length > 0

  activate: ->
    if @model.session.get "active"
      @clear()
      @widgets = new Coreon.Views.Widgets.WidgetsView
        model: @model
      @append "#coreon-top", @widgets.render()
      @footer = new Coreon.Views.Layout.FooterView
        model: @model.session
      @append @footer.render()

  deactivate: ->
    @clear()
    @login = new Coreon.Views.Account.LoginView
      model: @model.session
    @append "#coreon-main", @login.render()

  reauthorize: ->
    @destroy @prompt if @prompt
    @prompt = new Coreon.Views.Account.PasswordPromptView
      model: @model.session
    @append "#coreon-modal", @prompt.render()
    @$("#coreon-password-password").focus()

  reactivate: ->
    @destroy @prompt if @prompt
    dropped = @model.session.connections.filter (connection) ->
      connection.get("xhr").status == 403
    connection.resume() for connection in dropped

  onResize: ->
    @$("#coreon-main").css "paddingTop": @header.$el.outerHeight()

  destroy: (subviews...) ->
    super subviews...
    @model.session.off null, null, @ if subviews.length is 0

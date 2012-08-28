#= require environment
#= require templates/application
#= require views/header_view
#= require views/widgets_view
#= require views/footer_view
#= require views/login_view
#= require views/password_prompt_view

class Coreon.Views.ApplicationView extends Backbone.View

  template: Coreon.Templates["application"]

  events: "click a[href^='/']": "navigate"

  initialize: ->
    @header        = new Coreon.Views.HeaderView collection: @model.account.notifications
    @widgets       = new Coreon.Views.WidgetsView
    @footer        = new Coreon.Views.FooterView model: @model
    @login         = new Coreon.Views.LoginView model: @model.account
    @prompt        = new Coreon.Views.PasswordPromptView model: @model.account

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

  onReactivated: ->
    @prompt.remove()

  onResize: ->
    @login.$el.css "paddingTop": @header.$el.outerHeight()

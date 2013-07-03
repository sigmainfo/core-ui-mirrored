#= require environment
#= require templates/application
#= require views/sessions/new_session_view
#= require views/notifications/notification_view
#= require views/widgets/widgets_view
#= require views/account/password_prompt_view
#= require views/repositories/repository_select_view
#= require views/layout/progress_indicator_view


class Coreon.Views.ApplicationView extends Backbone.View

  template: Coreon.Templates["application"]

  events:
    "click a[href^='/']": "navigate"
    "click #coreon-footer .toggle": "toggle"

  initialize: ->
    @session = null
    @main = null
    @modal = null
    @listenTo @model, "change:session", @render
    @listenTo Coreon.Models.Notification.collection(), "add", @notify
    @listenTo Coreon.Models.Notification.collection(), "reset", @clearNotifications

  render: ->
    subview.remove() for subview in @subviews if @subviews
    @subviews = []
    session = @updateSession()
    @$el.html @template session: session
    if session?
      widgets = new Coreon.Views.Widgets.WidgetsView model: @model
      @$("#coreon-modal").after widgets.render().$el
      @subviews.push widgets
      repoSelect = new Coreon.Views.Repositories.RepositorySelectView
        model: session
        app: @
      @$("#coreon-filters").append repoSelect.render().$el
      @subviews.push repoSelect
      progress = new Coreon.Views.Layout.ProgressIndicatorView
        el: @$("#coreon-progress-indicator")
      @subviews.push progress
      Backbone.history.start pushState: on unless Backbone.History.started
      @$("#coreon-account").delay(2000).slideUp()
    else
      Backbone.history.stop()
      @switch new Coreon.Views.Sessions.NewSessionView model: @model

  switch: (screen) ->
    @main?.remove()
    if @main = screen
      screen.render()
      @$("#coreon-main").append screen.$el

  prompt: (modal) ->
    @modal?.remove()
    if @modal = modal
      modal.render()
      @$("#coreon-modal").empty().append modal.$el

  notify: (notification) ->
    view = new Coreon.Views.Notifications.NotificationView model: notification
    @$("#coreon-notifications").append view.render().$el

  clearNotifications: ->
    @$("#coreon-notifications").empty()

  navigate: (event) ->
    event.preventDefault()
    Backbone.history.navigate $(event.target).closest("a").attr("href")[1..], trigger: true

  toggle: (event) ->
    $(event.target).closest(".toggle").siblings().slideToggle()

  reauthenticate: (model, token) ->
    @prompt if token
      null
    else
      new Coreon.Views.Account.PasswordPromptView
        model: @model.get "session"

  repository: (id) ->
    session = @model.get "session"
    if session?
      session.set "current_repository_id", id
      session.currentRepository()
    else
      null

  query: (query) ->
    input = @$ "#coreon-search-query"
    hint = @$ "#coreon-search-target-select .hint"
    input.val query if query?
    if query then hint.hide() else hint.show()
    input.val()

  updateSession: ->
    previous = @session
    session = @model.get "session"
    @stopListening previous if previous?
    if session?
      @listenTo session, "change:current_repository_id", @render
      @listenTo session, "change:auth_token", @reauthenticate
    @session = session

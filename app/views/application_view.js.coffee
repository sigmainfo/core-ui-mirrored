#= require environment
#= require templates/application
#= require views/sessions/new_session_view
#= require views/notifications/notification_view
#= require views/widgets/widgets_view
#= require views/account/password_prompt_view
#= require views/repositories/repository_select_view
#= require views/layout/progress_indicator_view
#= require lib/panels/panels_manager
#= require modules/helpers
#= require modules/prompt
#= require modules/xhr_forms
#= require models/repository_settings

class Coreon.Views.ApplicationView extends Backbone.View

  Coreon.Modules.include @, Coreon.Modules.Prompt
  Coreon.Modules.include @, Coreon.Modules.XhrForms

  template: Coreon.Templates["application"]

  events:
    "click a[href^='/']"           : "navigate"
    "click #coreon-footer .toggle" : "toggle"
    'click .themes a[data-name]'   : 'switchTheme'

  initialize: ->
    @session = null
    @main = null
    @modal = null

    @stopListening()
    @listenTo @model, "change:session", @render
    @listenTo @model, "change:query", @updateQuery
    @listenTo Coreon.Models.Notification.collection(), "add", @notify
    @listenTo Coreon.Models.Notification.collection(), "reset", @clearNotifications

    @xhrFormsOn()
    @panels = Coreon.Lib.Panels.PanelsManager.create @

  render: ->
    @panels.removeAll()
    subview.remove() for subview in @subviews if @subviews
    @subviews = []
    session = @updateSession()
    @$el.html @template session: session
    if session?
      $.when(Coreon.Models.RepositorySettings.refresh(true), session.get('repository').getStats())
        .done =>
          widgets = new Coreon.Views.Widgets.WidgetsView
            model: @model
          @$("#coreon-modal").after widgets.render().$el
          @subviews.push widgets

          # repoSelect = new Coreon.Views.Repositories.RepositorySelectView
          #   model: session
          #   app: @
          # @$("#coreon-filters").append repoSelect.render().$el
          # @subviews.push repoSelect

          progress = new Coreon.Views.Layout.ProgressIndicatorView
            el: @$("#coreon-progress-indicator")
          @subviews.push progress

          @panels.createAll()
          @panels.update()

          # Backbone.history.start pushState: on unless Backbone.History.started

          # @$('#coreon-account').delay(2000).slideUp()
        .always =>
          repoSelect = new Coreon.Views.Repositories.RepositorySelectView
            model: session
            app: @
          @$("#coreon-filters").append repoSelect.render().$el
          @subviews.push repoSelect

          Backbone.history.start pushState: on unless Backbone.History.started

        @$('#coreon-account').delay(2000).slideUp()
    else
      Backbone.history.stop()
      login = new Coreon.Views.Sessions.NewSessionView model: @model
      @subviews.push login
      if location.search.match /[?&]guest=/
        login.createGuestSession()
      else
        @$('#coreon-main').append login.render().$el
      history.replaceState {}, '', location.href.replace(/\?.*$/, '')

  notify: (notification) ->
    view = new Coreon.Views.Notifications.NotificationView model: notification
    @$("#coreon-notifications").append view.render().$el.hide()
    view.show()
    @listenTo view, "resize", @syncOffset

  clearNotifications: ->
    @$("#coreon-notifications").empty()

  syncOffset: ->
    header = $("#coreon-header").outerHeight(on)
    filters = $('#coreon-filters').outerHeight(on)
    top = header + filters
    $("#coreon-main").css 'top', "#{top}px"

  navigate: (event) ->
    event.preventDefault()
    Coreon.Lib.ConceptMap.RenderStrategy.do_not_refresh = true
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
    if session = @model.get "session"
      session.set "current_repository_id", id unless arguments.length is 0
      session.currentRepository()
    else
      null

  updateQuery: ->
    input = @$ "#coreon-search-query"
    hint = @$ "#coreon-search-target-select .hint"
    if query = @model.get('query')
      input.val query
      hint.hide()
    else
      input.val ''
      hint.show()

  updateSession: ->
    previous = @session
    session = @model.get "session"
    @stopListening previous if previous?
    if session?
      @listenTo session, "change:current_repository_id", @render
      @listenTo session, "change:auth_token", @reauthenticate
    @session = session

  switchTheme: (event) ->
    event.preventDefault()

    el = $ event.target
    name = el.data 'name'

    link = $('#coreon-theme')
    current = link.attr 'href'
    next = current.replace /[^/]+\.css/, "#{name}.css"
    link.attr 'href', next

    @$('.themes a.selected').removeClass 'selected'
    el.addClass 'selected'

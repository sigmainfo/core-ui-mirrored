#= require environment
#= require templates/sessions/new_session
#= require helpers/action_for
#= require models/session
#= require models/notification
#= require modules/helpers
#= require modules/loop

class Coreon.Views.Sessions.NewSessionView extends Backbone.View

  Coreon.Modules.include @, Coreon.Modules.Loop

  id: "coreon-login"

  template: Coreon.Templates["sessions/new_session"]

  events:
    "submit form"  : "create"

  initialize: ->
    @startLoop @updateState

  render: ->
    @$el.html @template()
    @

  updateState: (event) ->
    valid = @$("#coreon-login-email").val().length and @$("#coreon-login-password").val().length
    @$("input[type='submit']").prop "disabled", not valid

  create: (event) ->
    event.preventDefault()
    @stopLoop()
    @$("input,button").prop "disabled", yes
    Coreon.Models.Session.authenticate(@$("#coreon-login-email").val(), @$("#coreon-login-password").val())
      .done( (session) =>
        @model.set "session", session
        if session?
          Coreon.Models.Notification.info I18n.t "notifications.account.login", name: session.get("user").name
        else
          @$("#coreon-login-password").val ""
          @$("input,button").prop "disabled", no
          @startLoop @updateState
      )

  remove: ->
    @stopLoop()
    super

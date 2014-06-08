#= require environment
#= require templates/sessions/new_session
#= require helpers/action_for
#= require helpers/form_for
#= require models/session
#= require models/notification
#= require modules/helpers
#= require modules/loop

class Coreon.Views.Sessions.NewSessionView extends Backbone.View

  Coreon.Modules.include @, Coreon.Modules.Loop

  id: "coreon-login"

  events:
    "submit form"  : "create"

  initialize: (options = {}) ->
    @template = options.template or Coreon.Templates['sessions/new_session']
    @startLoop @updateState

  render: ->
    @$el.html @template()
    @

  updateState: (event) ->
    valid = @$('input[type="email"]').val().length and
      @$('input[type="password"]').val().length
    @$('*[type="submit"]').prop "disabled", not valid

  create: (event) ->
    event.preventDefault()
    @stopLoop()
    @$("input,button").prop "disabled", yes
    Coreon.Models.Session.authenticate(@$('input[type="email"]').val()
                                     , @$('input[type="password"]').val()
    )
      .done (session) =>
        @model.set "session", session
        if session?
          Coreon.Models.Notification.info I18n.t 'notifications.account.login'
                                        , name: session.get('user').name
        else
          @$('input[type="password"]').val ""
          @$("input,button").prop "disabled", no
          @startLoop @updateState

  remove: ->
    @stopLoop()
    super

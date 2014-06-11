#= require environment
#= require templates/sessions/new_session
#= require helpers/action_for
#= require helpers/form_for
#= require models/session
#= require models/notification
#= require modules/helpers
#= require modules/loop

class Coreon.Views.Sessions.NewSessionView extends Backbone.View

  @GUEST_EMAIL    = 'guest@coreon.com'
  @GUEST_PASSWORD = 'TaiD@?mkPVWmh7hj&HgguBom647i&A'

  Coreon.Modules.include @, Coreon.Modules.Loop

  id: 'coreon-login'

  events:
    'submit form'                  : 'createSession'
    'click a.create-guest-session' : 'createGuestSession'

  initialize: (options = {}) ->
    @template = options.template or Coreon.Templates['sessions/new_session']
    @startLoop @updateState

  render: ->
    @$el.html @template()
    @

  $email: ->
    @$ 'input[type="email"]'

  $password: ->
    @$ 'input[type="password"]'

  $submit: ->
    @$ '*[type="submit"]'

  updateState: ->
    valid = @$email().val().length and @$password().val().length
    @$submit().prop 'disabled', not valid

  createSession: ->
    @authenticate @$email().val(), @$password().val()

  createGuestSession: ->
    {GUEST_EMAIL, GUEST_PASSWORD} = @constructor
    @authenticate GUEST_EMAIL, GUEST_PASSWORD

  authenticate: (email, password) ->
    @stopLoop()
    @$('input,button').prop 'disabled', yes
    Coreon.Models.Session.authenticate(email, password)
      .done (session) =>
        @model.set 'session', session
        if session?
          Coreon.Models.Notification.info I18n.t 'notifications.account.login'
                                        , name: session.get('user').name
        else
          @$password().val ''
          @$('input,button').prop 'disabled', no
          @startLoop @updateState


  remove: ->
    @stopLoop()
    super

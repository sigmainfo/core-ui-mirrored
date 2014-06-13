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
    @authenticate null

  authenticate: (email, password) ->
    @stopLoop()
    @$('input,button').prop 'disabled', yes

    Coreon.Models.Session.authenticate(email, password)
      .done (session) =>
        @model.set 'session', session
        unless session?
          @$password().val ''
          @$('input,button').prop 'disabled', no
          @startLoop @updateState

  remove: ->
    @stopLoop()
    super

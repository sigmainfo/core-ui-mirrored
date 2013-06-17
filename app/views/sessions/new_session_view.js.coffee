#= require environment
#= require templates/sessions/new_session
#= require models/session

class Coreon.Views.Sessions.NewSessionView extends Backbone.View

  id: "coreon-login"

  template: Coreon.Templates["sessions/new_session"]

  events:
    "submit form"  : "create"
    "change input" : "updateState"
    "keyup input"  : "updateState"
    "paste input"  : "updateState"
    "cut input"    : "updateState"

  render: ->
    @$el.html @template()
    @

  updateState: (event) ->
    valid = @$("#coreon-login-email").val().length and @$("#coreon-login-password").val().length
    @$("input[type='submit']").prop "disabled", not valid

  create: (event) ->
    event.preventDefault()
    @$("input,button").prop "disabled", yes
    Coreon.Models.Session.create(@$("#coreon-login-email").val(), @$("#coreon-login-password").val())
      .fail( => @$("#coreon-login-password").val "" )
      .done( (session) => @model.set "session", session )

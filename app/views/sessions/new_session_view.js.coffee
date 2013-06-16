#= require environment
#= require templates/sessions/new_session

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
    @model.activate @$("#coreon-login-email").val(), @$("#coreon-login-password").val()

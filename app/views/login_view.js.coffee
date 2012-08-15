#= require environment
#= require templates/login

class Coreon.Views.LoginView extends Backbone.View
  id: "coreon-login"

  template: Coreon.Templates["login"]

  events:
    "submit form"  : "submitHandler"
    "change input" : "changeStateHandler"
    "keyup input"  : "changeStateHandler"
    "paste input"  : "changeStateHandler"

  render: ->
    @$el.html @template()
    @

  changeStateHandler: (event) ->
    valid = @$("#coreon-login-login").val().length and @$("#coreon-login-password").val().length
    @$("input[type='submit']").prop "disabled", not valid

  submitHandler: (event) ->
    event.preventDefault()
    event.stopPropagation()
    @model.login @$("#coreon-login-login").val(), @$("#coreon-login-password").val()

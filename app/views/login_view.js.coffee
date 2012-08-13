#= require environment
#= require templates/login

class Coreon.Views.LoginView extends Backbone.View
  id: "coreon-login"

  template: Coreon.Templates["login"]

  events:
    "submit form": "submitHandler"

  render: ->
    @$el.html @template()
    @

  submitHandler: (event) ->
    event.preventDefault()
    event.stopPropagation()
    @model.login @$("#coreon-login-login").val(), @$("#coreon-login-password").val()

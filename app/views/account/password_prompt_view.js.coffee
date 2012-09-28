#= require environment
#= require views/simple_view
#= require templates/account/password_prompt

class Coreon.Views.Account.PasswordPromptView extends Coreon.Views.SimpleView
  id: "coreon-password-prompt"

  events:
    "submit form": "onSubmit"
    "blur input#coreon-password-password": "onBlur"
    "click a.logout": "logout"

  template: Coreon.Templates["account/password_prompt"]

  render: ->
    @$el.html @template message: I18n.t "account.password_prompt.message"
    @

  onSubmit: (event) ->
    event.preventDefault()
    event.stopPropagation()
    @model.reactivate @$("#coreon-password-password").val()

  onBlur: ->
    @$("#coreon-password-password").focus()

  logout: (event) ->
    event.preventDefault()
    event.stopPropagation()
    @remove()
    @model.deactivate()


#= require environment
#= require templates/password_prompt
#= require helpers/link_to

class Coreon.Views.PasswordPromptView extends Backbone.View
  id: "coreon-password-prompt"

  events:
    "submit form": "onSubmit"
    "blur input#coreon-password-password": "onBlur"
    "click a.logout": "logout"

  template: Coreon.Templates["password_prompt"]

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


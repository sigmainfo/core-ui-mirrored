#= require environment
#= require templates/password_prompt
#= require helpers/link_to

class Coreon.Views.PasswordPromptView extends Backbone.View
  id: "coreon-password-prompt"

  template: Coreon.Templates["password_prompt"]

  render: ->
    @$el.html @template message: I18n.t "account.password_prompt.message"

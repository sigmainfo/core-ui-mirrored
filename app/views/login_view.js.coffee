#= require environment
#= require templates/login

class Coreon.Views.LoginView extends Backbone.View
  id: "coreon-login"

  template: Coreon.Templates["login"]

  render: ->
    @$el.html @template()
    @

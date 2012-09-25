#= require environment
#= require views/simple_view
#= require templates/account/account

class Coreon.Views.Account.AccountView extends Coreon.Views.SimpleView
  id: "coreon-account"

  template: Coreon.Templates["account/account"]

  events:
    "click a.logout": "logout"

  render: ->
    @$el.html @template name: @model.get "name"
    @

  logout: (event) ->
    event.preventDefault()
    event.stopPropagation()
    @model.deactivate()

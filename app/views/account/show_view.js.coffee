#= require environment
#= require helpers/link_to
#= require templates/account/show

class Coreon.Views.Account.ShowView extends Backbone.View
  id: "coreon-account"

  template: Coreon.Templates["account/show"]

  events:
    "click a.logout": "logout"

  render: ->
    @$el.html @template()
    @

  logout: (event) ->
    event.preventDefault()
    event.stopPropagation()
    @model.logout()
    Backbone.history.navigate "account/login", trigger: true, replace: true

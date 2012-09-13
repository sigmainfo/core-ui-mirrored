#= require environment
#= require templates/account

class Coreon.Views.AccountView extends Backbone.View
  id: "coreon-account"

  template: Coreon.Templates["account"]

  events:
    "click a.logout": "logout"

  render: ->
    @$el.html @template name: @model.get "name"
    @

  logout: (event) ->
    event.preventDefault()
    event.stopPropagation()
    @model.deactivate()

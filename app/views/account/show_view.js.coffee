#= require environment
#= require templates/account/show

class Coreon.Views.Account.ShowView extends Backbone.View
  id: "coreon-account"
  className: "footer"

  template: Coreon.Templates["account/show"]

  render: ->
    @$el.html @template()
    @

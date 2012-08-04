#= require environment
#= require helpers/link_to
#= require templates/account/show

class Coreon.Views.Account.ShowView extends Backbone.View
  id: "coreon-account"

  template: Coreon.Templates["account/show"]

  render: ->
    @$el.html @template()
    @

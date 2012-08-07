#= require environment
#= require templates/footer
#= require views/account_view

class Coreon.Views.FooterView extends Backbone.View
  id: "coreon-footer"

  template: Coreon.Templates["footer"]

  events:
    "click .toggle": "toggle"

  render: ->
    @$el.html @template()
    @$el.append (new Coreon.Views.AccountView model: @model.account).render().$el.hide()
    @

  toggle: ->
    @$el.children(":not(.toggle)").slideToggle()
    @

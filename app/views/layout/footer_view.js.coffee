#= require environment
#= require templates/layout/footer
#= require views/account/show_view

class Coreon.Views.Layout.FooterView extends Backbone.View
  id: "coreon-footer"

  template: Coreon.Templates["layout/footer"]

  events:
    "click .toggle": "toggle"

  render: ->
    @$el.html @template()
    @$el.append (new Coreon.Views.Account.ShowView model: @model.account).render().$el.hide()
    @

  toggle: ->
    @$el.children(":not(.toggle)").slideToggle()
    @

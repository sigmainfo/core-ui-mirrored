#= require environment
#= require templates/application/footer
#= require views/composite_view
#= require views/account/account_view
#= require views/layout/progress_indicator_view

class Coreon.Views.Layout.FooterView extends Coreon.Views.CompositeView
  id: "coreon-footer"

  template: Coreon.Templates["application/footer"]

  events:
    "click .toggle": "toggle"

  initialize: ->
    super
    @progress = new Coreon.Views.Layout.ProgressIndicatorView collection: @model.connections

  render: ->
    @$el.html @template()
    @$(".toggle").prepend @progress.render().$el
    @$el.append (new Coreon.Views.Account.AccountView model: @model).render().$el.hide()
    @

  toggle: ->
    @$el.children(":not(.toggle)").slideToggle()
    @

#= require environment
#= require templates/footer
#= require views/account_view
#= require views/progress_indicator_view

class Coreon.Views.FooterView extends Backbone.View
  id: "coreon-footer"

  template: Coreon.Templates["footer"]

  events:
    "click .toggle": "toggle"

  initialize: ->
    @progress = new Coreon.Views.ProgressIndicatorView collection: @model.connections

  render: ->
    @$el.html @template()
    @$(".toggle").prepend @progress.render().$el
    @$el.append (new Coreon.Views.AccountView model: @model.account).render().$el.hide()
    @

  toggle: ->
    @$el.children(":not(.toggle)").slideToggle()
    @

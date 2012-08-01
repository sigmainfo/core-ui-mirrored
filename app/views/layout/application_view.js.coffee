#= require environment
#= require views/layout/footer_view

class Coreon.Views.Layout.ApplicationView extends Backbone.View

  render: ->
    @$el.empty()
    @$el.append (new Coreon.Views.Layout.FooterView).render().$el
    @

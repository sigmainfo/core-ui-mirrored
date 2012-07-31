#= require environment
#= require views/account/show_view

class Coreon.Views.Layout.ApplicationView extends Backbone.View

  render: ->
    @$el.empty()
    @$el.append (new Coreon.Views.Account.ShowView).render().$el
    @

#= require environment
#= require views/layout/footer_view

class Coreon.Views.Layout.ApplicationView extends Backbone.View

  events: "click a": "navigate"

  render: ->
    @$el.empty()
    @$el.append (new Coreon.Views.Layout.FooterView).render().$el
    @

  navigate: (event)->
    location = $(event.target).attr "href"
    if location.indexOf("/") == 0
      Backbone.history.navigate location, trigger: true
      event.preventDefault()


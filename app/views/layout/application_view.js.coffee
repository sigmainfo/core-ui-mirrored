#= require environment
#= require views/layout/footer_view

class Coreon.Views.Layout.ApplicationView extends Backbone.View

  events: "click a[href^='/']": "navigate"

  render: ->
    @$el.empty()
    @$el.append (new Coreon.Views.Layout.FooterView model: @model).render().$el
    @

  navigate: (event) ->
    Backbone.history.navigate $(event.target).attr("href"), trigger: true
    event.preventDefault()

#= require environment
#= require views/tools_view
#= require views/footer_view

class Coreon.Views.ApplicationView extends Backbone.View

  events: "click a[href^='/']": "navigate"

  render: ->
    @$el.empty()
    @$el.append (new Coreon.Views.ToolsView model: @model).render().$el
    @$el.append (new Coreon.Views.FooterView model: @model).render().$el
    @

  navigate: (event) ->
    Backbone.history.navigate $(event.target).attr("href"), trigger: true
    event.preventDefault()

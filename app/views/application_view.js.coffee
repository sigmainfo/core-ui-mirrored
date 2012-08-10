#= require environment
#= require views/tools_view
#= require views/footer_view

class Coreon.Views.ApplicationView extends Backbone.View

  events: "click a[href^='/']": "navigate"

  initialize: ->
    @tools  = new Coreon.Views.ToolsView model: @model
    @footer = new Coreon.Views.FooterView model: @model

  render: ->
    @$el.empty()
    @$el.append @tools.render().$el
    @$el.append @footer.render().$el unless @model.account.idle()
    @

  navigate: (event) ->
    Backbone.history.navigate $(event.target).attr("href"), trigger: true
    event.preventDefault()

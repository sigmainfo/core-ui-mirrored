#= require environment
#= require views/notifications_view
#= require templates/tools

class Coreon.Views.ToolsView extends Backbone.View
  id: "coreon-tools"

  template: Coreon.Templates["tools"]

  render: ->
    @$el.html @template()
    @$("#coreon-status").append (new Coreon.Views.NotificationsView collection: @model.notifications).render().$el
    @
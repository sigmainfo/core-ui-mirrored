#= require environment
#= require templates/concepts/root

class Coreon.Views.Concepts.RootView extends Backbone.View

  template: Coreon.Templates["concepts/root"]

  render: ->
    @$el.html @template()
    @

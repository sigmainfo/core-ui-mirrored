#= require environment
#= require templates/properties/edit_properties

class Coreon.Views.Properties.EditPropertiesView extends Backbone.View

  template: Coreon.Templates["properties/edit_properties"]

  render: ->
    @$el.html @template()
    @

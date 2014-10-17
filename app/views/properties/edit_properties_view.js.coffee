#= require environment
#= require templates/properties/edit_properties
#= require views/properties/property_fieldset_view

class Coreon.Views.Properties.EditPropertiesView extends Backbone.View

  template: Coreon.Templates["properties/edit_properties"]

  initialize: ->
    @fieldsetViews = []
    for group in @collection
      @fieldsetViews.push new Coreon.Views.Properties.PropertyFieldsetView(model: group)

  render: ->
    @$el.html @template()
    _.each @fieldsetViews, (fieldset) =>
      @$el.append fieldset.render().$el
    @

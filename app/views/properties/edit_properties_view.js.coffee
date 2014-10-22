#= require environment
#= require templates/properties/edit_properties
#= require views/properties/property_fieldset_view

class Coreon.Views.Properties.EditPropertiesView extends Backbone.View

  template: Coreon.Templates["properties/edit_properties"]

  initialize: ->
    @fieldsetViews = []
    for formattedProperty, index in @collection
      @fieldsetViews.push new Coreon.Views.Properties.PropertyFieldsetView(model: formattedProperty, index: index)

  render: ->
    @$el.html @template()
    _.each @fieldsetViews, (fieldsetView) =>
      @$el.append fieldsetView.render().el
    @

  serializeArray: ->
    _.map @fieldsetViews, (fieldsetView) =>
      fieldsetView.serializeArray()


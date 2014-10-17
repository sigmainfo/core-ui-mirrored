#= require environment
#= require templates/properties/property_fieldset

class Coreon.Views.Properties.PropertyFieldsetView extends Backbone.View

  tagName: 'fieldset'

  className: 'property'

  template: Coreon.Templates["properties/property_fieldset"]

  initialize: ->

  render: ->
    @$el.html @template(property: @model)
    @
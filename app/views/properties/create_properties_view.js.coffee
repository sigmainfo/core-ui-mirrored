#= require environment
#= require templates/properties/create_properties
#= require views/properties/create_property_view

class Coreon.Views.Properties.CreatePropertiesView extends Backbone.View

  className: "create-properties"

  template: Coreon.Templates["properties/create_properties"]

  events:
    'click .section-toggle': 'toggle'
    'click .add_property': 'add_property'
  
  render: ->
    @$el.empty()
    @$el.html @template
    for property, id in @model.get("properties")
      create_property_view = new Coreon.Views.Properties.CreatePropertyView model: @model, id: id, property: property
      create_property_view.render()
      @$el.find('.section').append create_property_view.el

  toggle: (event) =>
    $(event.target).siblings().addBack().toggleClass "collapsed"

  add_property: (event) =>
    properties = @model.get "properties"
    properties.push { key: "", value: "", lang: "" }
    @model.set "properties",  properties
    @render()


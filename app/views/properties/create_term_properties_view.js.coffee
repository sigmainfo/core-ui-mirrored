#= require environment
#= require templates/properties/create_term_properties
#= require views/properties/create_term_property_view

class Coreon.Views.Properties.CreateTermPropertiesView extends Backbone.View

  className: "create-term-properties"

  template: Coreon.Templates["properties/create_term_properties"]

  events:
    'click .section-toggle': 'toggle'
    'click .add_property': 'add_property'
  
  render: ->
    @$el.empty()
    @$el.html @template
    for property, id in @model.get("terms")[@options.term_id].properties
      create_term_property_view = new Coreon.Views.Properties.CreateTermPropertyView model: @model, term_id: @options.term_id, id: id, property: property
      create_term_property_view.render()
      @$el.find('.section').append create_term_property_view.el

  toggle: (event) =>
    $(event.target).siblings().addBack().toggleClass "collapsed"

  add_property: (event) =>
    terms = @model.get "terms"
    properties = terms[@options.term_id].properties
    properties.push { key: "", value: "", language: "" }
    @model.set "terms", terms
    @render()

  add_term_property: (event) ->
    element = $(event.target)
    terms = @model.get "terms"
    term = terms[@options.id]
    term.properties.push { key: "", value: "", language: "" }
    @model.set "terms", terms
    @render()



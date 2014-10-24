#= require environment
#= require templates/properties/edit_properties
#= require views/properties/property_fieldset_view
#= require lib/select

class Coreon.Views.Properties.EditPropertiesView extends Backbone.View

  template: Coreon.Templates["properties/edit_properties"]

  events:
    'change select[name=chooseProperty]': 'addProperty'
    'click a.add-property': 'selectProperty'

  initialize: (options) ->
    @collection = options.collection
    @optionalProperties = options.optionalProperties || []
    @fieldsetViews = []
    @index = 0
    for formattedProperty, index in @collection
      @fieldsetViews.push new Coreon.Views.Properties.PropertyFieldsetView(model: formattedProperty, index: index)
      @index = @index++

  render: ->
    @$el.html @template(optionalProperties: @optionalProperties)
    @$el.find('select.widget-select').coreonSelect(positionRelativeTo: 'a.add-property', hidden: true)
    _.each @fieldsetViews, (fieldsetView) =>
      @$el.find('.add').before fieldsetView.render().el
    debugger
    @

  serializeArray: ->
    properties = []
    _.each @fieldsetViews, (fieldsetView) ->
      _.each fieldsetView.serializeArray(), (property) ->
        properties.push property
    properties

  selectProperty: ->
    $('.coreon-select[data-select-name=chooseProperty]').click()

  addProperty: (event) ->
    selectedKey = $(event.target).val()
    newPropertyBlueprint = _.find @optionalProperties, (p) -> p.key == selectedKey
    newPropertyFormatter = new Coreon.Formatters.PropertiesFormatter [newPropertyBlueprint],
      [new Coreon.Models.Property(key: selectedKey)],
      []
    newFormattedProperty = newPropertyFormatter.all()[0]
    newFieldset = new Coreon.Views.Properties.PropertyFieldsetView
      model: newFormattedProperty
      index: @index
    @index = @index++
    @fieldsetViews.push newFieldset
    @$el.find('.add').before newFieldset.render().el




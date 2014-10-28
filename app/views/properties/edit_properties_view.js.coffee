#= require environment
#= require templates/properties/edit_properties
#= require views/properties/property_fieldset_view
#= require lib/select

class Coreon.Views.Properties.EditPropertiesView extends Backbone.View

  tagName: 'section'

  className: 'properties'

  template: Coreon.Templates["properties/edit_properties"]

  events:
    'change select[name=chooseProperty]': 'addProperty'
    'click a.add-property': 'selectProperty'

  initialize: (options) ->
    @collection = options.collection
    @optionalProperties = options.optionalProperties || []
    @isEdit = options.isEdit || false
    @collapsed = options.collapsed || false
    @ownerId = options.ownerId
    @fieldsetViews = []
    @index = 0
    for formattedProperty, index in @collection
      newFieldsetView = new Coreon.Views.Properties.PropertyFieldsetView(model: formattedProperty, index: index)
      @fieldsetViews.push newFieldsetView
      @listenTo newFieldsetView, 'inputChanged', @updateValid
      @index = @index++
    @$el.addClass('collapsed') if @collapsed
    @$el.addClass('edit') if @isEdit
    @valid = false

  render: ->
    @$el.html @template(optionalProperties: @optionalProperties)
    @$el.find('select.widget-select').coreonSelect(positionRelativeTo: 'a.add-property', hidden: true)
    _.each @fieldsetViews, (fieldsetView) =>
      @$el.find('.add').before fieldsetView.render().el
    @

  isValid: ->
    for fieldsetView in @fieldsetViews
      unless fieldsetView.isValid()
        return false
    true

  updateValid: ->
    @trigger 'updateValid'
    @valid = @isValid()

  markInvalid: ->
    for fieldsetView in @fieldsetViews
      fieldsetView.markInvalid() unless fieldsetView.isValid()

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
    newFieldsetView = new Coreon.Views.Properties.PropertyFieldsetView
      model: newFormattedProperty
      index: @index
    @listenTo newFieldsetView, 'inputChanged'
    @index = @index++
    @fieldsetViews.push newFieldsetView
    @$el.find('.add').before newFieldsetView.render().el




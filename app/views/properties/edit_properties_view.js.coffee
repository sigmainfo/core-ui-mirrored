#= require environment
#= require templates/properties/edit_properties
#= require templates/properties/select_property_popup
#= require views/properties/property_fieldset_view
#= require lib/select

class Coreon.Views.Properties.EditPropertiesView extends Backbone.View

  tagName: 'section'

  className: 'properties edit'

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
      @listenTo newFieldsetView, 'removeProperty', @removeProperty
      @index++
    @$el.addClass('collapsed') if @collapsed
    @$el.addClass('edit') if @isEdit

  render: ->
    @$el.html @template(optionalProperties: @optionalProperties)
    @renderAddPropertyPopUp()
    _.each @fieldsetViews, (fieldsetView) =>
      fieldsetView.delegateEvents()
      @$el.find('.add').before fieldsetView.render().el
    @

  renderAddPropertyPopUp: ->
    @$el.find('.coreon-select.widget-select[data-select-name=chooseProperty]').remove()
    @$el.find('select.widget-select').remove()
    link = @$el.find('.add .edit a.add-property')
    remainingOptionalProperties = @remainingOptionalProperties()
    if remainingOptionalProperties.length > 0
      link.removeClass("disabled")
      link.after Coreon.Templates['properties/select_property_popup'](optionalProperties: remainingOptionalProperties)
      @$el.find('select.widget-select').coreonSelect(positionRelativeTo: @$el.find('a.add-property'), hidden: true, allowSingle: true)
    else
      link.addClass("disabled")

  remainingOptionalProperties: ->
    _.filter @optionalProperties, (p) =>
      !_.find @fieldsetViews, (v) -> v.model.key == p.key

  isValid: ->
    for fieldsetView in @fieldsetViews
      unless fieldsetView.isValid()
        return false
    true

  updateValid: ->
    @trigger 'updateValid'

  serializeArray: ->
    properties = []
    _.each @fieldsetViews, (fieldsetView) ->
      _.each fieldsetView.serializeArray(), (property) ->
        properties.push property
    properties

  serializeAssetsArray: ->
    assetProperties = []
    _.each @fieldsetViews, (fieldsetView) ->
      _.each fieldsetView.serializeAssetsArray(), (assetProperty) ->
        assetProperties.push assetProperty
    assetProperties

  countDeleted: ->
    count = 0
    _.each @fieldsetViews, (fieldsetView) ->
      count = count + fieldsetView.checkDelete()
    count

  selectProperty: ->
    @$el.find('.coreon-select[data-select-name=chooseProperty]').click()

  nonMultivaluedExists: (property)->
    found = _.find @fieldsetViews, (view) ->
      view.model.key == property.key
    found

  addProperty: (event) ->
    selectedKey = $(event.target).val()
    newPropertyBlueprint = _.find @optionalProperties, (p) -> p.key == selectedKey
    return if @nonMultivaluedExists(newPropertyBlueprint)
    newPropertyFormatter = new Coreon.Formatters.PropertiesFormatter [newPropertyBlueprint],
      [new Coreon.Models.Property(key: selectedKey, persisted: false)],
      []
    newFormattedProperty = newPropertyFormatter.all()[0]
    newFieldsetView = new Coreon.Views.Properties.PropertyFieldsetView
      model: newFormattedProperty
      index: @index
    @listenTo newFieldsetView, 'inputChanged', @updateValid
    @listenTo newFieldsetView, 'removeProperty', @removeProperty
    @index++
    @fieldsetViews.push newFieldsetView
    @$el.find('.add').before newFieldsetView.render().el
    @renderAddPropertyPopUp()
    @updateValid()

  removeProperty: (fieldsetView) ->
    if fieldsetView.containsPersisted()
      fieldsetView.markDelete()
    else
      index = _.indexOf @fieldsetViews, fieldsetView
      @fieldsetViews.splice index, 1
      fieldsetView.remove()
    @renderAddPropertyPopUp()





#= require environment
#= require templates/properties/property_fieldset
#= require templates/properties/text_property_fieldset_value
#= require templates/properties/multiline_text_property_fieldset_value
#= require helpers/render
#= require helpers/select_field
#= require helpers/text_field
#= require helpers/text_area_field
#= require helpers/check_box_field
#= require helpers/multi_select_field
#= require helpers/boolean_field

class Coreon.Views.Properties.PropertyFieldsetView extends Backbone.View

  tagName: 'fieldset'

  className: 'property'

  template: Coreon.Templates["properties/property_fieldset"]

  events:
    'change select': 'inputChanged'
    'input input': 'inputChanged'
    'click a.add-value': 'addValue'
    'click a.remove-value': 'removeValue'
    'click a.remove-property': 'removeProperty'

  initialize: (options) ->
    @model = options.model
    @index = options.index
    @scopePrefix = options.scopePrefix
    @name = if @scopePrefix? then "#{@scopePrefix}[properties][#{@index}]" else "properties[#{@index}]"
    @selectableLanguages = Coreon.Models.RepositorySettings.languageOptions()
    @values_index = @model?.properties.length || 0

  render: ->
    @$el.html @template(property: @model, name: @name, selectableLanguages: @selectableLanguages)
    @updateRemoveLinks()
    @

  isValid: ->
    for result in @serializeArray()
      if !result.key? || !result.value? || (result.value is '')
        return false
    true

  markInvalid: ->
    @$el.find('.key').after $ '<div class="invalid">Property required</div>'

  serializeArray: ->
    return [] if !@model.multivalue && @checkDelete() == 1
    @$el.find('.group').not('.delete').map (index, group) =>
      switch @model.type
        when 'text'
          {
            key: @model.key
            value: $(group).find('input').val()
            lang: $(group).find('select').val()
          }
        when 'multiline_text'
          {
            key: @model.key
            value: $(group).find('textarea').val()
            lang: $(group).find('select').val()
          }
        when 'number'
          {
            key: @model.key
            value: Number($(group).find('input').val())
          }
        when 'boolean'
          {
            key: @model.key
            value: if $(group).find('input:radio:checked').val() == 'true' then true else false
          }
        when 'multiselect_picklist'
          {
            key: @model.key
            value: _.map($(group).find("input:checkbox:checked"), (c) -> $(c).val())
          }
        when 'picklist'
          {
            key: @model.key
            value: $(group).find('select').val()
          }

  checkDelete: ->
    if @model.multivalue
      return @$el.find('.group.delete').length
    else
      return 1 if @$el.hasClass 'delete'
    0

  markDelete: ->
    @$el.addClass 'delete'

  inputChanged: (evt) ->
    @trigger 'inputChanged'

  addValue: ->
    return unless @model.type in ['text', 'multiline_text']
    newValueTemplate = Coreon.Templates["properties/#{@model.type}_property_fieldset_value"]
    newValueMarkup = newValueTemplate(propertyKey: @model.key, name: @name, property: {}, index: @values_index, selectableLanguages: @selectableLanguages)
    @$el.append newValueMarkup
    @values_index++
    @updateRemoveLinks()

  removeValue: (event) ->
    propertyGroup = $(event.target).parent()
    index = propertyGroup.attr('data-index')
    if @model.properties[index]
      propertyGroup.addClass('delete')
    else
      propertyGroup.remove()
    if @$el.find('.group').not('.delete').length > 0
      @updateRemoveLinks()
    else
      @removeProperty()


  updateRemoveLinks: ->
    if @model.multivalue
      if @model.required
        if @$el.find('.group').not('.delete').length > 1
          @$el.find('.group').not('.delete').find('a.remove-value').css('display', '')
        else
          @$el.find('.group').not('.delete').find('a.remove-value').css('display', 'none')
      else
        @$el.find('.group').not('.delete').find('a.remove-value').css('display', '')

  removeProperty: ->
    unless @model.multivalue && !@model.required && @containsPersisted()
      @trigger 'removeProperty', @

  containsPersisted: ->
    true if _.find(@model.properties, (p) -> p.persisted)




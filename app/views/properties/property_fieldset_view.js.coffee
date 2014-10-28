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

  initialize: (options) ->
    @model = options.model
    @index = options.index
    @scopePrefix = options.scopePrefix
    @name = if @scopePrefix? then "#{@scopePrefix}[properties][#{@index}]" else "properties[#{@index}]"
    @selectableLanguages = Coreon.Models.RepositorySettings.languageOptions()
    @values_index = @model?.properties.length || 0

  render: ->
    @$el.html @template(property: @model, name: @name, selectableLanguages: @selectableLanguages)
    @

  isValid: ->
    for result in @serializeArray()
      unless !!result.key && !!result.value
        return false
    true

  markInvalid: ->
    @$el.find('.key').after $ '<div class="invalid">Property required</div>'

  serializeArray: ->
    @$el.find('.group').map (index, group) =>
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

  inputChanged: (evt) ->
    @trigger 'inputChanged'

  addValue: ->
    return unless @model.type in ['text', 'multiline_text']
    newValueTemplate = Coreon.Templates["properties/#{@model.type}_property_fieldset_value"]
    newValueMarkup = newValueTemplate(propertyKey: @model.key, name: @name, property: {}, index: @values_index, selectableLanguages: @selectableLanguages)
    @$el.append newValueMarkup
    @values_index++

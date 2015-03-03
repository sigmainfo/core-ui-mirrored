#= require environment
#= require templates/properties/property_fieldset
#= require templates/properties/text_property_fieldset_value
#= require templates/properties/multiline_text_property_fieldset_value
#= require templates/properties/asset_property_fieldset_value
#= require helpers/render
#= require helpers/select_field
#= require helpers/text_field
#= require helpers/text_area_field
#= require helpers/check_box_field
#= require helpers/multi_select_field
#= require helpers/boolean_field
#= require helpers/file_field
#= require lib/select
#= require lib/dom

class Coreon.Views.Properties.PropertyFieldsetView extends Backbone.View

  tagName: 'fieldset'

  className: 'property'

  template: Coreon.Templates["properties/property_fieldset"]

  events:
    'change select': 'inputChanged'
    'input input': 'inputChanged'
    'input textarea': 'inputChanged'
    'change input[type=file]': 'assetChanged',
    'click [type="checkbox"]': 'inputChanged'
    'click [type="radio"]': 'inputChanged'
    'click a.add-value': 'addValue'
    'click a.remove-value': 'removeValue'
    'click a.remove-property': 'removeProperty'

  initialize: (options) ->
    @model = options.model
    @index = options.index
    @scopePrefix = options.scopePrefix
    @name = if @scopePrefix? then "#{@scopePrefix}[properties][#{@index}]" else "properties[#{@index}]"
    @selectableLanguages = Coreon.Models.RepositorySettings.languageOptions()
    @values_index = @model?.properties?.length || 0

  render: ->
    @$el.addClass 'required' if @model.required
    @$el.addClass @model.type
    @$el.html @template(property: @model, name: @name, selectableLanguages: @selectableLanguages)
    @updateRemoveLinks()
    @$el.find('select').coreonSelect()
    @

  serializeArray: ->
    @$el.find('.group').map (index, group) =>
      property = null
      if $(group).hasClass 'delete'
        property = {
          _destroy: "1"
        }
      else
        property = switch @model.type
          when 'text'
            {
              value: $(group).find('input:text').val()
              lang: $(group).find('select').val()
            }
          when 'multiline_text'
            {
              value: $(group).find('textarea').val()
              lang: $(group).find('select').val()
            }
          when 'number'
            if $(group).find('input:text').val() != null && $(group).find('input:text').val() != ''
              value = Number($(group).find('input:text').val())
              value = null if isNaN(value)
            else
              value = null
            {
              value: value
            }
          when 'date'
            {
              value: $(group).find('input:text').val()
            }
          when 'boolean'
            {
              value: if $(group).find('input:radio:checked').val() == 'true' then true else false
            }
          when 'multiselect_picklist'
            {
              value: _.map($(group).find("input:checkbox:checked"), (c) -> $(c).val())
            }
          when 'picklist'
            {
              value: $(group).find('select').val()
            }
      if property?
        property.key = @model.key
        property.type = @model.type
        if !!$(group).find('input:hidden').val()
          property.id = $(group).find('input:hidden').val()
      property

  serializeAssetsArray: ->
    return [] if !@model.multivalue && @checkDelete() == 1
    @$el.find('.group').not('.delete').map (index, group) =>
      if (@model.type is 'asset') && $(group).find('input:file').length > 0
        {
          key: @model.key
          type: @model.type
          lang: $(group).find('select').val()
          value: if $(group).find('input:text').val()? then $(group).find('input:text').val() else $(group).find('input:file').get(0).files[0].name
          asset: $(group).find('input:file').get(0).files[0]
        }

  isValid: ->
    for result in @serializeAssetsArray()
      return false unless result.asset
    for result in @serializeArray()
      valid = switch
        when result._destroy == "1" then true
        when !result.key? then false
        when (typeof result.value == 'object') && _.isEmpty(result.value) then false
        when (result.type is 'text') && _.isEmpty(result.value) then false
        else true
      return false if !valid
    true

  checkDelete: ->
    if @model.multivalue
      @$el.find('.group.delete').length
    else if @$el.hasClass 'delete'
      1
    else
      0

  markDelete: ->
    @$el.addClass 'delete'
    @$el.find('.group').addClass 'delete'
    @$el.find('input,textarea,button').prop 'disabled', true
    @inputChanged()

  assetChanged: (evt) ->
    if @model.type is 'asset'
      @previewAsset(evt)

  inputChanged: (evt) ->
    @trigger 'inputChanged'

  addValue: ->
    return unless @model.multivalue
    newValueTemplate = Coreon.Templates["properties/#{@model.type}_property_fieldset_value"]
    newValueMarkup = newValueTemplate(propertyKey: @model.key, name: @name, property: {}, index: @values_index, selectableLanguages: @selectableLanguages)
    newValueMarkup = $ newValueMarkup
    newValueMarkup.find('select').coreonSelect()
    @$el.append newValueMarkup
    @values_index++
    unless newValueMarkup.isOnScreen()
      newValueMarkup.scrollToReveal()
    @updateRemoveLinks()
    @inputChanged()

  removeValue: (event) ->
    propertyGroup = $(event.target).parent()
    index = propertyGroup.attr('data-index')
    if @model.properties[index] && @model.properties[index].persisted
      propertyGroup.addClass('delete')
    else
      propertyGroup.remove()
    if @$el.find('.group').not('.delete').length > 0
      @updateRemoveLinks()
    else
      @removeProperty()
    @inputChanged()


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
    if _.find(@model.properties, (p) -> p.persisted) then true else false

  previewAsset: (evt) ->
    file = evt.target.files[0]
    reader = new FileReader();
    reader.onload = (event) =>
      theUrl = event.target.result
      if file.type.match /^image/i
        $(evt.target).closest('.group').find('.asset-preview').html "<figure class=\"image\"><img src='" + theUrl + "' /></figure>"
      else
        $(evt.target).closest('.group').find('.asset-preview').html "<figure class=\"other\"><img src='/assets/generic_asset.png' /></figure>"

      $(evt.target).closest('.group').find('input[type=text]').val file.name
      $(evt.target).closest('.group').find('.input.value').css 'display', 'block'
      $(evt.target).closest('.group').find('.input.lang').css 'display', 'block'
      $(evt.target).closest('.group').find('input[type=file]').css 'display', 'none'
      @trigger 'inputChanged'
    reader.readAsDataURL file





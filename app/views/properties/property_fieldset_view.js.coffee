#= require environment
#= require templates/properties/property_fieldset
#= require helpers/select_field
#= require helpers/text_field
#= require helpers/text_area_field
#= require helpers/check_box_field
#= require helpers/multi_select_field

class Coreon.Views.Properties.PropertyFieldsetView extends Backbone.View

  tagName: 'fieldset'

  className: 'property'

  template: Coreon.Templates["properties/property_fieldset"]

  initialize: (options) ->
    @model = options.model
    @index = options.index
    @scopePrefix = options.scopePrefix
    @name = if @scopePrefix? then "#{@scopePrefix}[properties][#{@index}]" else "properties[#{@index}]"
    @selectableLanguages = Coreon.Models.RepositorySettings.languageOptions()

  render: ->
    @$el.html @template(property: @model, name: @name, selectableLanguages: @selectableLanguages)
    @
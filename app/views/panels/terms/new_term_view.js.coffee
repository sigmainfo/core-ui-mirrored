#= require environment
#= require templates/concepts/_new_term
#= require helpers/input
#= require views/properties/edit_properties_view

class Coreon.Views.Panels.Terms.NewTermView extends Backbone.View

  tagName: 'fieldset'

  className: 'term'

  template: Coreon.Templates["concepts/new_term"]

  initialize: (options) ->
    @model = options.model
    @index = options.index || 0
    @errors = options.errors
    @scopePrefix = options.scopePrefix || null
    @name = if @scopePrefix? then "#{@scopePrefix}[terms][#{@index}]" else "terms[#{@index}]"
    @editProperties = new Coreon.Views.Properties.EditPropertiesView
      collection: @model.propertiesWithDefaults()
      optionalProperties: Coreon.Models.RepositorySettings.optionalPropertiesFor('term')
      isEdit: true
    @selectableLanguages = Coreon.Models.RepositorySettings.languageOptions()

  render: ->
    @$el.html @template(term: @model, name: @name, errors: @errors, selectableLanguages: @selectableLanguages)
    @$el.attr('data-index', @index)
    @$el.append @editProperties.render().$el
    @

  serializeArray: ->
    {
      value: @$el.find("input[name=\"#{@name}[value]\"]").val(),
      lang: @$el.find("select[name=\"#{@name}[lang]\"]").val(),
      properties: @editProperties.serializeArray()
    }


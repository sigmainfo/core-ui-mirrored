#= require environment
#= require templates/concepts/create_concept
#= require templates/concepts/create_concept_validation_failure
#= require views/concepts/concept_tree_view
#= require views/properties/create_property_view
#= require views/terms/create_term_view

class Coreon.Views.Concepts.CreateConceptView extends Backbone.View

  termCount: 0
  propertyCount: 0

  className: "concept create-concept"

  template: Coreon.Templates["concepts/create_concept"]

  template_validation_failure: Coreon.Templates["concepts/create_concept_validation_failure"]

  events:
    'click .add_term': 'addTerm'
    'click .add_property': 'addProperty'
    'click .create': 'create'
    'click .cancel': 'cancel'

  initialize: ->
    @listenTo @model, 'validationFailure', @validationFailure

  render: ->
    @$el.html @template concept: @model
    for term in @model.get("terms")?.models ? []
      term_view = new Coreon.Views.Terms.CreateTermView index: @termCount, model: term
      @termCount += 1
      @$('.terms').append term_view.render().$el
    for property in @model.get("properties") ? []
      property_view = new Coreon.Views.Properties.CreatePropertyView property: property, index: @propertyCount, model: @model
      @propertyCount += 1
      @$('.properties').append property_view.render().$el
    @

  validationFailure: (errors = {}) ->
    @$('.errors').html @template_validation_failure
    if errors.terms?.length
      @$('.errors ul').append "<li>" + I18n.t("create_concept.validation_failure_terms") + "</li>"
      @_addSubErrors errors.nested_errors_on_terms, "term", ["value", "language"]
    if errors.properties?.length
      @$('.errors ul').append "<li>" + I18n.t("create_concept.validation_failure_properties") + "</li>"
      @_addSubErrors errors.nested_errors_on_properties, "property", ["key", "value", "language"]
            
  _addSubErrors: (errors, type, fields) ->
    if errors
      for error, index in errors when error
        for field in fields
          field_name = if field is "language" then "lang" else field
          if error[field_name]?.length
            @$(".create-#{type}:eq(#{index}) .#{field} .input").addClass "error"
            if error[field_name][0] is "can't be blank"
              @$(".create-#{type}:eq(#{index}) .#{field} .error_message").html I18n.t "create_#{type}.#{field}_cant_be_blank"

  _removeErrors: ->
    @$('.input').removeClass "error"
    @$('.error_message').empty()

  create: (event) ->
    @_removeErrors()
    @model.set @_formToJs(), silent:true
    #console.log JSON.stringify  @model.toJSON()
    #Coreon.Models.collection.create @model
    @model.create()

  _formToJs: ->
    conceptJs = properties: [], terms: []
    for term in @$('.create-term')
      conceptJs.terms.push
        value: $(term).find('.value input').val()
        lang: $(term).find('.language input').val()
    for property in @$('.create-property')
      conceptJs.properties.push
        key: $(property).find('.key input').val()
        value: $(property).find('.value input').val()
      lang = $(property).find('.language input').val()
      conceptJs.properties[conceptJs.properties.length-1]["lang"] = lang if lang
    conceptJs

  cancel: (event) ->
    window.history.back()

  addTerm: (event) ->
    event.stopPropagation()
    term_view = new Coreon.Views.Terms.CreateTermView index: @termCount
    @termCount += 1
    @$('.terms').append term_view.render().$el

  addProperty: (event) ->
    event.stopPropagation()
    property_view = new Coreon.Views.Properties.CreatePropertyView index: @propertyCount
    @propertyCount += 1
    @$('.properties').append property_view.render().$el

    #renderTitle: ->
    #@$('h2.label').text @model.get('label')


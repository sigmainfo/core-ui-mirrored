#= require environment
#= require templates/concepts/create_concept
#= require templates/concepts/create_concept_validation_failure
#= require views/concepts/concept_tree_view
#= require views/properties/create_property_view
#= require views/terms/create_term_view

class Coreon.Views.Concepts.CreateConceptView extends Backbone.View

  className: "concept create-concept"

  template: Coreon.Templates["concepts/create_concept"]

  template_validation_failure: Coreon.Templates["concepts/create_concept_validation_failure"]

  events:
    'click .add_term': 'addTerm'
    'click .add_property': 'addProperty'
    'click .create': 'create'
    'click .cancel': 'cancel'

  initialize: ->
    @listenTo @model, 'add:terms remove:terms add:properties remove:properties', @render
    @listenTo @model, 'change:terms change:properties', @renderTitle
    @listenTo @model, 'validationFailure', @validationFailure

  render: ->
    @$el.html @template concept: @model
    for term in @model.get("terms")?.models ? []
      term_view = new Coreon.Views.Terms.CreateTermView model: term
      @$('.terms').append term_view.render().$el
    for property, index in @model.get("properties") ? []
      property_view = new Coreon.Views.Properties.CreatePropertyView property: property, id: index, model: @model
      @$('.properties').append property_view.render().$el
    @

  validationFailure: (errors = {}) ->
    @$('.errors').html @template_validation_failure
    @$('.errors ul').append "<li>" + I18n.t("create_concept.validation_failure_terms") + "</li>" if errors.terms?.length
    @$('.errors ul').append "<li>" + I18n.t("create_concept.validation_failure_properties") + "</li>" if errors.properties?.length

  create: (event) ->
    @model.create()

  cancel: (event) ->
    window.history.back()

  addTerm: (event) ->
    event.stopPropagation()
    @model.addTerm()

  addProperty: (event) ->
    event.stopPropagation()
    @model.addProperty()

  renderTitle: ->
    @$('h2.label').text @model.get('label')

#  render_label: () =>
#    label = @model.get "label"
#    #TODO: move into model
#    label = I18n.t "create_concept.no_label" if label == ""
#    @$el.find(".label").html label
#
#  create: (event) =>
#    @model.save( null, { success: @on_success, error: @on_error } )
#
#  on_error: (model, xhr, options) =>
#    if xhr.statusText == "Unprocessable Entity"
#      errors = jQuery.parseJSON( xhr.responseText ).errors
#      console.log errors
#
#  on_success: (model, resp, options) =>
#    Backbone.history.navigate "/concepts/#{@model.id}", {trigger: true}
#
#  cancel: (event) =>
#    window.history.back()
#
#  destroy: =>
#    @remove()
#

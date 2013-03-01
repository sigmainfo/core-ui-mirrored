#= require environment
#= require templates/concepts/create_concept
#= require views/concepts/concept_tree_view
#= require views/properties/create_properties_view
#= require views/terms/create_terms_view

class Coreon.Views.Concepts.CreateConceptView extends Backbone.View

  className: "concept create-concept"

  template: Coreon.Templates["concepts/create_concept"]

  events:
    'click .add_term': 'add_term'
  #  'click .create': 'create'
  #  'click .cancel': 'cancel'

  initialize: ->
    @listenTo @model, 'add:terms', @render
    @listenTo @model, 'change:terms', @render_title

  render: ->
    @$el.html @template concept: @model
    @model.get("terms")?.each (term, index) =>
      term_view = new Coreon.Views.Terms.CreateTermView model: term
      @$('.terms').append term_view.render().$el
    @

  add_term: ->
    @model.add_term()

  render_title: ->
    @$('h2.label').text @model.get('label')



#    #    if @model.get("super_concept_ids")?.length + @model.get("sub_concept_ids")?.length > 0
#    #  @$el.append new Coreon.Views.Concepts.ConceptTreeView model: @model
#    create_properties_view = new Coreon.Views.Properties.CreatePropertiesView model: @model
#    create_properties_view.render()
#    @$el.find('.properties').replaceWith create_properties_view.el
#
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

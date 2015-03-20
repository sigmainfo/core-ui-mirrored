#= require environment
#= require helpers/form_for
#= require templates/concepts/shared/associative_relations
#= require views/concepts/shared/associative_relations/show_view
#= require views/concepts/shared/associative_relations/edit_view

class Coreon.Views.Concepts.Shared.AssociativeRelationsView extends Backbone.View

  tagName: "section"

  className: "associative-relations"

  template: Coreon.Templates["concepts/shared/associative_relations"]

  events:
    "click .edit-relations"                 : "toggleEditMode"
    "click .submit .cancel:not(.disabled)"  : "cancelUpdate"
    "submit form"                           : "updateRelations"
    "click .submit .reset:not(.disabled)"   : "resetRelations"

  initialize: (options) ->
    @editing = no
    @concept = options.concept
    @collection = options.collection

  render: ->
    @relationViews = []
    @$el.html @template editing: @editing, concept: @concept
    _(@collection).each (relation) =>
      if !@editing
        relationView = new Coreon.Views.Concepts.Shared.AssociativeRelations.ShowView model: relation
      else
        relationView = new Coreon.Views.Concepts.Shared.AssociativeRelations.EditView model: relation
      @relationViews.push relationView

      @$el.find('table.associative-types').append relationView.render().$el
    @

  toggleEditMode: ->
    @editing = !@editing
    @render()

  cancelUpdate: (evt) ->
    evt.preventDefault()
    evt.stopPropagation()
    @toggleEditMode()

  resetRelations: (evt) ->
    evt.preventDefault()
    evt.stopPropagation()
    @render()

  updateRelations: (evt) ->
    evt.preventDefault()
    evt.stopPropagation()
    relations = []

    _(@relationViews).each (relView) ->
      relations.push relView.serializeArray()

    data =
      other_relations: _(relations).flatten()

    deferred = @concept.save data, attrs: {concept: data}, wait: true

    deferred.done =>
      @concept.fetch
        success: =>
          @toggleEditMode()

    deferred.fail =>




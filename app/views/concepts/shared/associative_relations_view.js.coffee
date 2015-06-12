#= require environment
#= require helpers/form_for
#= require templates/concepts/shared/associative_relations
#= require views/concepts/shared/associative_relations/show_view
#= require views/concepts/shared/associative_relations/edit_view
#= require modules/droppable

class Coreon.Views.Concepts.Shared.AssociativeRelationsView extends Backbone.View

  Coreon.Modules.include @, Coreon.Modules.Droppable

  tagName: "section"

  className: "associative-relations"

  attributes:
    "data-name": "associative-relations"

  template: Coreon.Templates["concepts/shared/associative_relations"]

  events:
    "click .edit-relations"                 : "toggleEditMode"
    "click .submit .cancel:not(.disabled)"  : "cancelUpdate"
    "submit form"                           : "updateRelations"
    "click .submit .reset:not(.disabled)"   : "resetRelations"

  initialize: (options) ->
    @editing = no
    @parentEditing = options.parentEditing
    @concept = options.concept
    @collection = options.collection

  render: ->
    @relationViews = []
    @$el.html @template editing: @editing, concept: @concept
    _(@collection).each (relation) =>
      relationView = null
      if !@editing
        if relation.relations?.length > 0
          relationView = new Coreon.Views.Concepts.Shared.AssociativeRelations.ShowView model: relation
      else
        relationView = new Coreon.Views.Concepts.Shared.AssociativeRelations.EditView model: relation
      if relationView?
        @relationViews.push relationView
        @$el.find('table.associative-types').append relationView.render().$el
    if @editing
      @droppableOn @$el, "ui-droppable-disconnect",
        accept: (item) => @checkRemoval(item)
        drop: (evt, ui)=> @removeRelation(evt, ui)

    @collapse() if _(Coreon.application.repositorySettings('collapsedSections')).indexOf('associative-relations') > -1

    @

  collapse: ->
    @$el.addClass 'collapsed'
    @$el.find('h3').siblings().not(".edit").css('display', 'none')

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

  checkRemoval: (item) ->
    (@$el.has($(item)).length > 0) && $(item).hasClass("from-connection-list")

  removeRelation: (evt, ui) ->
    targetView = _(@relationViews).find (v) =>
      ui.draggable.closest('tr.relation-type')[0] is v.$el[0]
    targetView.disconnect(ui.draggable) if targetView?





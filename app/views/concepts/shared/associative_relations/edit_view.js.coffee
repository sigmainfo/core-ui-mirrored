#= require environment
#= require templates/concepts/shared/associative_relations/edit
#= require views/concepts/concept_label_view
#= require modules/droppable

class Coreon.Views.Concepts.Shared.AssociativeRelations.EditView extends Backbone.View

  Coreon.Modules.include @, Coreon.Modules.Droppable

  tagName: "tr"

  className: "relation-type edit-mode"

  template: Coreon.Templates["concepts/shared/associative_relations/edit"]

  initialize: ->
    @relations = _(@model.relations).map (r) -> Coreon.Models.Concept.find r.id

  render: ->
    for el in @$(".ui-droppable")
      @droppableOff(el)
    @droppableOff(@$el) if @$el.hasClass('.ui-droppable')
    @$el.html @template title: @model.relationType.key, icon: @model.relationType.icon
    _(@relations).each (relation) =>
      relationElement = $("<li>")
      relationElement.append @createConceptLabel(relation)
      @$el.find('td.relations ul').append relationElement
    @droppableOn @$("td.relations ul"), "ui-droppable-connect",
      accept: (item) -> true
      drop: (evt, ui)=> @onDrop("td.relations", ui.draggable)
      out: (evt, ui)=> @onDropOut(evt, ui)
      over: (evt, ui)=> @onDropOver(evt, ui)
    @

  createConceptLabel: (relation) ->
    label = new Coreon.Views.Concepts.ConceptLabelView model: relation
    label.$el.addClass "from-connection-list"
    label.render().$el

  onDrop: (dropzone, item) =>
    conceptId = item.data "drag-ident"
    return false if @checkIfExists(conceptId)
    @relations.push Coreon.Models.Concept.find conceptId
    @render()

  onDropOut: (evt, ui) ->
    conceptId = $(ui.helper).data("drag-ident")
    $(ui.helper).removeClass "ui-droppable-connect"
    $(ui.draggable.context).draggable "option", "revert", "invalid"

  onDropOver: (evt, ui)->
    conceptId = $(ui.draggable.context).attr("data-drag-ident")
    if @checkIfExists(conceptId)
      $(ui.draggable.context).draggable "option", "revert", true
      $(evt.target).removeClass "ui-state-hovered"
    else
      $(ui.helper).addClass "ui-droppable-connect"

  disconnect: (item) ->
    conceptId = item.data "drag-ident"
    found = @checkIfExists(conceptId)
    @relations = _(@relations).without(found) if found?
    item.remove()
    @render()

  checkIfExists: (id) ->
    found = _(@relations).find (rel) ->
      rel.get('id') is id

  serializeArray: ->
    _(@relations).map (rel) =>
      {
        type: @model.relationType.key,
        id: rel.get 'id'
      }







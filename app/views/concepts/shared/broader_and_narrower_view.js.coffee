#= require environment
#= require helpers/repository_path
#= require helpers/can
#= require templates/concepts/shared/broader_and_narrower
#= require templates/repositories/repository_label
#= require views/concepts/concept_label_view
#= require models/concept
#= require modules/droppable

class Coreon.Views.Concepts.Shared.BroaderAndNarrowerView extends Backbone.View

  Coreon.Modules.include @, Coreon.Modules.Droppable

  tagName: "section"

  className: "broader-and-narrower"

  template: Coreon.Templates["concepts/shared/broader_and_narrower"]
  repositoryLabel: Coreon.Templates["repositories/repository_label"]

  events:
    "submit form": "updateConceptConnections"
    "click .edit-connections": "toggleEditMode"

  concepts: null

  initialize: ->
    @broader = []
    @narrower = []
    @$el.html @template id: @model.id, editable: !@model.isNew()
    @listenTo @model, "change:label", @renderSelf
    @listenTo @model, "change:super_concept_ids nonblank", @renderBroader
    @listenTo @model, "change:sub_concept_ids", @renderNarrower

    @droppableOn @$(".broader.edit"), "ui-droppable-connect",
      accept: (item)=> @dropItemAcceptance(item)
      drop: (evt, ui)=> @onDrop("broader", ui.helper.data("drag-ident"))
    @droppableOn @$(".narrower.edit"), "ui-droppable-connect",
      accept: (item)=> @dropItemAcceptance(item)
      drop: (evt, ui)=> @onDrop("narrower", ui.helper.data("drag-ident"))

  render: ->
    @renderSelf()
    @renderBroader()
    @renderNarrower()
    @

  renderSelf: ->
    @$(".self").html @model.escape "label"
    @$(".self").attr "data-drag-ident", @model.get("_id")

  renderBroader: ->
    @clearBroader()
    super_concept_ids = @model.get "super_concept_ids"
    if super_concept_ids.length > 0
      @broader = @renderConcepts @$(".broader.static ul"), super_concept_ids
      @broader.concat @renderConcepts @$(".broader.edit ul"), super_concept_ids
    else unless @model.blank
      @$(".broader ul").html "<li>#{@repositoryLabel repository: Coreon.application.get("session").currentRepository()}</li>"

  renderNarrower: ->
    @clearNarrower()
    @narrower = @renderConcepts @$(".narrower.static ul"), @model.get "sub_concept_ids"
    @narrower.concat @renderConcepts @$(".narrower.edit ul"), @model.get "sub_concept_ids"

  renderConcepts: (container, ids) ->
    container.empty()
    concepts = ( @createConcept id for id in ids )
    for concept in concepts
      concept_el = concept.render().$el
      concept_el.attr "data-drag-ident", concept.model.id
      container.append $("<li>").append concept_el
    concepts

  createConcept: (id) ->
    concept = new Coreon.Views.Concepts.ConceptLabelView
      model: Coreon.Models.Concept.find id
    concept

  remove: ->
    @clearBroader()
    @clearNarrower()
    super

  clearBroader: ->
    concept.remove() while concept = @broader.pop()

  clearNarrower: ->
    concept.remove() while concept = @narrower.pop()

  dropItemAcceptance: (item)->
    id = $(item).data "drag-ident"
    temporaryIds = ($(el).val() for el in @$("form li input[type=hidden]"))
    @model.acceptsConnection(id) && temporaryIds.indexOf(id) == -1

  onDrop: (broaderNarrower, ident)->
    temporaryConcept = @createConcept ident
    temporaryConceptEl = temporaryConcept.render().$el
    temporaryConceptEl.attr "data-drag-ident", ident
    listItem = $("<li>").append temporaryConceptEl

    if broaderNarrower is "broader"
      name = 'super_concept_ids[]'
      list = @$(".broader.edit ul")
    else
      name = 'sub_concept_ids[]'
      list = @$(".narrower.edit ul")

    listItem.append $("<input type='hidden' name='#{name}' value='#{ident}'>")
    list.append listItem

  onDropNarrower: (evt, ui)->
    console.log "would add to narrower concepts", ui.helper.data("drag-ident")

  updateConceptConnections: (evt) ->
    evt.preventDefault()
    data = $(evt.target).serializeJSON() or {}
    data.super_concept_ids.unshift @model.get("super_concept_ids")...
    data.sub_concept_ids.unshift @model.get("sub_concept_ids")...
    console.log data

  toggleEditMode: ->
    @editMode = !@editMode
    if @editMode
      @$("form").addClass("edit")
      @$("form").removeClass("show")
    else
      @$("form").removeClass("edit")
      @$("form").addClass("show")

#= require environment
#= require helpers/repository_path
#= require helpers/can
#= require templates/concepts/shared/broader_and_narrower
#= require templates/repositories/repository_label
#= require views/concepts/concept_label_view
#= require models/concept
#= require models/notification
#= require modules/droppable

class Coreon.Views.Concepts.Shared.BroaderAndNarrowerView extends Backbone.View

  Coreon.Modules.include @, Coreon.Modules.Droppable

  tagName: "section"

  className: "broader-and-narrower"

  template: Coreon.Templates["concepts/shared/broader_and_narrower"]
  repositoryLabel: Coreon.Templates["repositories/repository_label"]

  events:
    "click  .submit .cancel":   "cancelConceptConnections"
    "click  .submit .reset":    "resetConceptConnections"
    "submit  form":             "updateConceptConnections"
    "click   .concept-label":   "preventLabelClicks"
    "click  .edit-connections": "toggleEditMode"

  concepts: null

  initialize: ->
    @broader = []
    @narrower = []
    @$el.html @template id: @model.id, editable: !@model.isNew()
    @listenTo @model, "change:label", @renderSelf
    @listenTo @model, "change:superconcept_ids nonblank", @renderBroader
    @listenTo @model, "change:subconcept_ids", @renderNarrower

  render: ->
    @renderSelf()
    @renderBroader()
    @renderNarrower()
    @

  renderSelf: ->
    @$(".self").html @model.escape "label"
    @$(".self").attr "data-drag-ident", @model.get("id")

  renderBroader: ->
    @clearBroader()
    superconcept_ids = @model.get "superconcept_ids"
    if superconcept_ids.length > 0
      @broader = @renderConcepts @$(".broader.static ul"), superconcept_ids
      @broader.concat @renderConcepts @$(".broader.ui-droppable ul"), superconcept_ids
    else unless @model.blank
      @$(".broader.static ul").html "<li>#{@repositoryLabel repository: Coreon.application.get("session").currentRepository()}</li>"

  renderNarrower: ->
    @clearNarrower()
    @narrower = @renderConcepts @$(".narrower.static ul"), @model.get "subconcept_ids"
    @narrower.concat @renderConcepts @$(".narrower.ui-droppable ul"), @model.get "subconcept_ids"

  renderConcepts: (container, ids) ->
    container.empty()
    concepts = ( @createConcept id for id in ids )
    for concept in concepts
      concept_el = concept.render().$el
      concept_el.attr "data-drag-ident", concept.model.id
      concept_el.addClass "from-connection-list"
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
    id = $(item).data("drag-ident")     #TODO: .toString breaks it O_o
    temporaryAddedIds = ($(el).data("drag-ident") for el in @$(".list li [data-new-connection=true]"))
    temporaryRemovedIds = ($(el).data("drag-ident") for el in @$(".list li [data-deleted-connection=true]"))
    (temporaryRemovedIds.indexOf(id) >= 0 && temporaryAddedIds.indexOf(id) == -1) || (@model.acceptsConnection(id) && temporaryAddedIds.indexOf(id) == -1)

  onDrop: (broaderNarrower, item)->
    ident = item.data("drag-ident")

    if (existing = @$(".#{broaderNarrower} [data-drag-ident=#{ident}]")).length > 0
      existing.attr "data-deleted-connection", false
      existing.data "deleted-connection", false
      existing.parents("li").show()
      return existing

    temporaryConcept = @createConcept ident
    temporaryConceptEl = temporaryConcept.render().$el
    temporaryConceptEl.attr "data-drag-ident", ident
    temporaryConceptEl.attr "data-new-connection", true
    temporaryConceptEl.addClass "from-connection-list"
    listItem = $("<li>").append temporaryConceptEl

    if broaderNarrower is "broader"
      list = @$(".broader.ui-droppable ul")
    else
      list = @$(".narrower.ui-droppable ul")

    list.append listItem

  onDisconnect: (item)->
    ident = item.data("drag-ident")
    for el in @$("form li").has("[data-drag-ident=#{ident}]")
      $("[data-drag-ident]", el).attr "data-deleted-connection", true
      $(el).hide()
      _.defer => @$("[data-drag-ident=#{ident}][data-new-connection=true]").parents("li").remove()

  resetConceptConnections: (evt) ->
    evt.preventDefault()
    evt.stopPropagation()
    $(el).remove() for el in @$(".list li").has("[data-new-connection=true]")
    $(el).show() for el in @$(".list li").has("[data-deleted-connection=true]")

  cancelConceptConnections: (evt) ->
    @resetConceptConnections(evt)
    @toggleEditMode()

  updateConceptConnections: (evt) ->
    evt.preventDefault()
    data = { superconcept_ids: [], subconcept_ids: [] }

    for item in @$(".broader.ui-droppable [data-drag-ident]")
      data.superconcept_ids.push $(item).data("drag-ident") unless $(item).data "deleted-connection"

    for item in @$(".narrower.ui-droppable [data-drag-ident]")
      data.subconcept_ids.push $(item).data("drag-ident") unless $(item).data "deleted-connection"

    @$("form, .submit a").addClass "disabled"
    @$(".submit button").prop "disabled", true

    broaderAdded = []
    broaderDeleted = []
    narrowerAdded = []
    narrowerDeleted = []

    for el in @$('.broader.ui-droppable li [data-new-connection=true]')
      ident = $(el).data("drag-ident")
      broaderAdded.push Coreon.Models.Concept.find(ident).get("label") unless broaderAdded.indexOf(ident) >= 0
    for el in @$('.broader.ui-droppable li [data-deleted-connection=true]')
      ident = $(el).data("drag-ident")
      broaderDeleted.push Coreon.Models.Concept.find(ident).get("label") unless broaderDeleted.indexOf(ident) >= 0

    for el in @$('.narrower.ui-droppable li [data-new-connection=true]')
      ident = $(el).data("drag-ident")
      narrowerAdded.push Coreon.Models.Concept.find(ident).get("label") unless narrowerAdded.indexOf(ident) >= 0
    for el in @$('.narrower.ui-droppable li [data-deleted-connection=true]')
      ident = $(el).data("drag-ident")
      narrowerDeleted.push Coreon.Models.Concept.find(ident).get("label") unless narrowerDeleted.indexOf(ident) >= 0

    @model.save data,
      success: =>
        if (n = broaderAdded.length) > 0
          Coreon.Models.Notification.info I18n.t("notifications.concept.broader_added", count: n, label: broaderAdded[0])
        if (n = broaderDeleted.length) > 0
          Coreon.Models.Notification.info I18n.t("notifications.concept.broader_deleted", count: n, label: broaderDeleted[0])
        if (n = narrowerAdded.length) > 0
          Coreon.Models.Notification.info I18n.t("notifications.concept.narrower_added", count: n, label: narrowerAdded[0])
        if (n = narrowerDeleted.length) > 0
          Coreon.Models.Notification.info I18n.t("notifications.concept.narrower_deleted", count: n, label: narrowerDeleted[0])

        @toggleEditMode()
      error: (model) =>
        model.once "error", @render, @
      attrs:
        concept: data

  toggleEditMode: ->
    @editMode = !@editMode
    if @editMode
      @$("form").addClass("active")
      @$("form").removeClass("static")

      $(window).on "keydown.coreonSubmit", (event) =>
        @$("form").submit() if event.keyCode is 13

      @droppableOn @$(".broader.ui-droppable ul"), "ui-droppable-connect",
        accept: (item)=> @dropItemAcceptance(item)
        drop: (evt, ui)=> @onDrop("broader", ui.draggable)
      @droppableOn @$(".narrower.ui-droppable ul"), "ui-droppable-connect",
        accept: (item)=> @dropItemAcceptance(item)
        drop: (evt, ui)=> @onDrop("narrower", ui.draggable)

      @droppableOn @$(".catch-disconnect"), "ui-droppable-hovered",
        accept: (item)-> $(item).hasClass "from-connection-list"

      @droppableOn @$(".list"), "ui-droppable-disconnect",
        accept: (item)-> $(item).hasClass "from-connection-list"
        drop: (evt, ui)=> @onDisconnect(ui.draggable)

    else
      $(window).off ".coreonSubmit"
      @$("form").removeClass("active")
      @$("form").addClass("static")
      @droppableOff(el) for el in @$(".ui-droppable") if $(el).data("uiDroppable")

  preventLabelClicks: (evt)->
    if @editMode
      evt.preventDefault()
      evt.stopPropagation()

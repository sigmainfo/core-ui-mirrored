#= require environment
#= require collections/clips
#= require views/concepts/concept_label_view
#= require templates/widgets/clipboard
#= require modules/droppable

class Coreon.Views.Widgets.ClipboardView extends Backbone.View

  Coreon.Modules.include @, Coreon.Modules.Droppable

  id: "coreon-clipboard"
  className: "widget"
  template: Coreon.Templates["widgets/clipboard"]

  events:
    "click .clear": "clear"
    "drop": "onDropItem"

  _concept_label_views: []

  initialize: ->
    @listenTo @collection(), "add reset remove", @render
    @droppableOn @$el, "ui-droppable-clipboard",
      accept: (el) => @dropItemAcceptance(el)

  dropItemAcceptance: (item) ->
    not @collection().get item.data "drag-ident"

  onDropItem: (evt, ui) ->
    @$el.removeClass "ui-state-hovered"
    id = ui.draggable.data "drag-ident"
    model = Coreon.Models.Concept.find id
    @collection().add model

  render: ->
    clip.remove() while clip = @_concept_label_views.pop()

    @$el.html @template()
    ul = @$("ul")

    for clip in @collection().models
      view = new Coreon.Views.Concepts.ConceptLabelView model:clip
      ul.append $('<li>').append view.render().$el
    @

  collection: ->
    Coreon.Collections.Clips.collection()

  clear: ->
    @collection().reset []

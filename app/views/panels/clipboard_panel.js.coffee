#= require environment
#= require views/panels/panel_view
#= require collections/clips
#= require views/concepts/concept_label_view
#= require helpers/action_for
#= require helpers/titlebar
#= require templates/panels/clipboard
#= require modules/droppable

class Coreon.Views.Panels.ClipboardPanel extends Coreon.Views.Panels.PanelView

  Coreon.Modules.include @, Coreon.Modules.Droppable

  id: "coreon-clipboard"
  className: "widget"
  template: Coreon.Templates["panels/clipboard"]

  events:
    "click .clear": "clear"

  initialize: ->
    super

    @labels = []

    @$el.html @template
      actions: [
        'widgets.clipboard.clear'
      ]
    @droppableOn @$("ul"), "ui-droppable-clipboard",
      greedy: false
      accept: (el) => @dropItemAcceptance(el)
      drop: (evt, ui) => @onDropItem(evt, ui)
    @listenTo @collection(), "add reset remove", @render

  dropItemAcceptance: (item) ->
    not @collection().get item.data "drag-ident"

  onDropItem: (evt, ui) ->
    @$el.removeClass "ui-state-hovered"
    id = ui.draggable.data "drag-ident"
    model = Coreon.Models.Concept.find id
    @collection().add model

  render: ->
    label.remove() for label in @labels
    @labels = []

    ul = @$("ul").empty()

    for clip in @collection().models
      view = new Coreon.Views.Concepts.ConceptLabelView model: clip
      ul.append $('<li>').append view.render().$el
      @labels.push view
    @

  collection: ->
    Coreon.Collections.Clips.collection()

  clear: ->
    @collection().reset []

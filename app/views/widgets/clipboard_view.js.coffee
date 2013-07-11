#= require environment
#= require collections/clips
#= require views/concepts/concept_label_view
#= require templates/widgets/clipboard

class Coreon.Views.Widgets.ClipboardView extends Backbone.View

  collection: Coreon.Collections.Clips.collection()
  id: "coreon-clipboard"
  className: "widget"
  template: Coreon.Templates["widgets/clipboard"]

  _concept_label_views: []

  initialize: ->
    @listenTo @collection, "add remove reset", @onChange

  onChange: ->
    clip.remove() for clip in @_concept_label_views
    @_concept_label_views = []
    for clip in @collection.models
      @_concept_label_views.push new Coreon.Views.Concepts.ConceptLabelView model:clip
    @render()

  render: ->
    @$el.html @template()
    ul = @$("ul")
    for clip in @_concept_label_views
      ul.append $('<li>').append clip.render().$el
    @


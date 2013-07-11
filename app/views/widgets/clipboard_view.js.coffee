#= require environment
#= require collections/clips
#= require views/concepts/concept_label_view
#= require templates/widgets/clipboard

class Coreon.Views.Widgets.ClipboardView extends Backbone.View

  collection: Coreon.Collections.Clips.collection()
  id: "coreon-clipboard"
  template: Coreon.Templates["widgets/clipboard"]

  _concept_label_views: []

  initialize: ->
    @listenTo @collection, "add remove reset change:label", @onChange

  onChange: ->
    @_concept_label_views = []
    for clip in @collection.models
      @_concept_label_views.push new Coreon.Views.Concepts.ConceptLabelView model:clip
    @render()

  render: ->
    @$el.empty()
    clips = (view.render().el.outerHTML for view in @_concept_label_views)
    @$el.html @template clips: clips
    @


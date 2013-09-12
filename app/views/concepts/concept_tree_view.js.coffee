#= require environment
#= require views/layout/section_view
#= require templates/concepts/concept_tree
#= require views/concepts/concept_label_view

class Coreon.Views.Concepts.ConceptTreeView extends Coreon.Views.Layout.SectionView

  className: "concept-tree"

  template: Coreon.Templates["concepts/concept_tree"]

  sectionTitle: -> I18n.t "concept.tree"

  render: ->
    super
    @$(".section").html @template concept: @model
    if @model.get("superconcept_ids")
      for id in @model.get("superconcept_ids")
        @$(".super").append @concept(id)
    if @model.get("subconcept_ids")
      for id in @model.get("subconcept_ids")
        @$(".sub").append @concept(id)
    @

  concept: (id) ->
    label = new Coreon.Views.Concepts.ConceptLabelView id: id
    @add label.render()
    $("<li>").append label.$el


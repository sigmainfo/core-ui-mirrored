#= require environment
#= require templates/concepts/shared/broader_and_narrower
#= require templates/repositories/repository_label
#= require views/concepts/concept_label_view
#= require models/concept

class Coreon.Views.Concepts.Shared.BroaderAndNarrowerView extends Backbone.View

  tagName: "section"

  className: "broader-and-narrower"

  template: Coreon.Templates["concepts/shared/broader_and_narrower"]
  repositoryLabel: Coreon.Templates["repositories/repository_label"]

  concepts: null

  initialize: ->
    @broader = []
    @narrower = []
    @$el.html @template()
    @listenTo @model, "change:label", @renderSelf
    @listenTo @model, "change:super_concept_ids", @renderBroader
    @listenTo @model, "change:sub_concept_ids", @renderNarrower

  render: ->
    @renderSelf()
    @renderBroader()
    @renderNarrower()
    @

  renderSelf: ->
    @$(".self").html @model.escape "label"

  renderBroader: ->
    @clearBroader()
    @broader = @renderConcepts @$(".broader ul"), @model.get "super_concept_ids"
    if @broader.length is 0
      @$(".broader ul").html "<li>#{@repositoryLabel()}</li>"

  renderNarrower: ->
    @clearNarrower()
    @narrower = @renderConcepts @$(".narrower ul"), @model.get "sub_concept_ids"

  renderConcepts: (container, ids) ->
    container.empty()
    concepts = ( @createConcept id for id in ids )
    for concept in concepts
      container.append $("<li>").append concept.render().$el
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

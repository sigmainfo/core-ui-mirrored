#= require environment
#= require templates/concepts/concept_list
#= require templates/concepts/empty_list
#= require views/concepts/concept_label_view

class Coreon.Views.Concepts.ConceptListView extends Backbone.View

  tagName   : 'table'
  className : 'concept-list'

  template  : Coreon.Templates["concepts/concept_list"]
  emptyList : Coreon.Templates["concepts/empty_list"]

  initialize: ->
    @stopListening()
    @listenTo @model, 'change:done', @render

  render: ->
    unless @model.get 'done'
      @$el.html ''
    else
      results = @model.results()
      if results.length is 0
        @$el.html @emptyList query: @model.get 'query'
      else
        @$el.html @template concepts: results
        @$('.concept-list-item').each ( index, tr ) ->
          label = new Coreon.Views.Concepts.ConceptLabelView
            model: results[index]
          $(tr).find('tr.label td').append label.render().$el
    @

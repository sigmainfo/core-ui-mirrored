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
    @labels = []
    @broader = []

  render: ->
    label.remove() for label in @labels
    @labels = []
    for broader in @broader
      @stopListening broader
    @broader = []
    unless @model.get 'done'
      @$el.html ''
    else
      results = @model.results()
      if results.length is 0
        @$el.html @emptyList query: @model.get 'query'
      else
        @$el.html @template concepts: results
        @$('.concept-list-item').each ( index, tr ) =>
          concept = results[index]
          label = new Coreon.Views.Concepts.ConceptLabelView
            model: concept
          $tr = $ tr
          $tr.find('tr.label td').append label.render().$el
          @labels.push label

          broader = concept.broader()
          if broader.length > 1
            broader
              .sort ( a, b ) ->
                a.get('label').localeCompare b.get('label')
              .forEach ( parent ) =>
                @listenTo parent, 'change:label', @render
                @broader.push parent
          $els = broader.map ( parent ) =>
            label = new Coreon.Views.Concepts.ConceptLabelView
              model: parent
            @labels.push label
            label.render().$el
          $tr.find('tr.broader td').append $els...
    @

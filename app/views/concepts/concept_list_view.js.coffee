#= require environment
#= require templates/concepts/concept_list
#= require templates/concepts/concept_list/empty
#= require templates/concepts/concept_list/list
#= require views/concepts/concept_label_view
#= require views/concepts/concept_label_list_view
#= require views/concepts/concept_list/terms_view
#= require helpers/can

class Coreon.Views.Concepts.ConceptListView extends Backbone.View

  className: 'concept-list'

  template : Coreon.Templates['concepts/concept_list']
  info     : Coreon.Templates['concepts/concept_list/empty']
  list     : Coreon.Templates['concepts/concept_list/list']

  initialize: ->
    @stopListening()
    @listenTo Coreon.application.repositorySettings()
            , 'change:sourceLanguage change:targetLanguage'
            , @render

  createConceptPath = ->
    app = Coreon.application
    base = "#{app.get('repository').path()}/concepts"
    lang = app.lang()
    query = encodeURIComponent app.get('query')
    "#{base}/new/terms/#{lang}/#{query}"

  insertLabel = (concept, row) ->
    label = new Coreon.Views.Concepts.ConceptLabelView
      model: concept
    label.render()
    $(row).find('tr.label td').append label.$el

  insertBroader = (concepts, row) ->
    broader = new Coreon.Views.Concepts.ConceptLabelListView
      models: concepts
    broader.render()
    $(row).find('tr.broader td').append broader.$el

  insertTerms = (concept, row) ->
    terms = new Coreon.Views.Concepts.ConceptList.TermsView
      model: concept
    terms.render()
    $(row).find('table').append terms.$el

  render: ->
    app = Coreon.application
    if app.get('idle')
      @$el.html ''
    else
      @$el.html @template createConceptPath: createConceptPath()

      if @model.isEmpty()
        @$('table tbody').html @info query: app.get('query')
      else
        data = @model.map (concept) ->
          label: concept.get('label')
          definition: concept.definition()
        @$('table tbody').html @list concepts: data

      @$('tr.concept-list-item').each (index, row) =>
        concept = @model.at(index)
        insertLabel concept, row
        insertBroader concept.broader(), row
        insertTerms concept, row
    @

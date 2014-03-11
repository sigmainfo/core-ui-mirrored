#= require environment
#= require templates/panels/concepts/concept_list
#= require templates/panels/concepts/concept_list/empty
#= require templates/panels/concepts/concept_list/list
#= require views/concepts/concept_label_view
#= require views/concepts/concept_label_list_view
#= require views/panels/concepts/concept_list/terms_view
#= require helpers/can

class Coreon.Views.Panels.Concepts.ConceptListView extends Backbone.View

  className: 'concept-list'

  template : Coreon.Templates['panels/concepts/concept_list']
  info     : Coreon.Templates['panels/concepts/concept_list/empty']
  list     : Coreon.Templates['panels/concepts/concept_list/list']

  initialize: ->
    @stopListening()
    @listenTo Coreon.application.repositorySettings()
            , 'change:sourceLanguage change:targetLanguage'
            , @render

  createConceptPath = ->
    app = Coreon.application
    base = "#{app.get('repository').id}/concepts"
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
    terms = new Coreon.Views.Panels.Concepts.ConceptList.TermsView
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

  # initialize: ->
  #   @stopListening()
  #   @listenTo Coreon.application.repositorySettings()
  #           , 'change:sourceLanguage change:targetLanguage'
  #           , @render
  #   @labels = []
  #   @broader = []
  #
  # render: ->
  #   label.remove() for label in @labels
  #   @labels = []
  #   for broader in @broader
  #     @stopListening broader
  #   @broader = []
  #   unless @model.get 'done'
  #     @$el.html ''
  #   else
  #     results = @model.results()
  #     sourceLang = Coreon.application.sourceLang()
  #     if not sourceLang? or sourceLang is 'none'
  #       sourceLang = 'en'
  #     @$el.html @template
  #       sourceLang: sourceLang
  #       query: @model.get 'query'
  #       concepts: results.map ( concept ) ->
  #         terms = concept.termsByLang()
  #         langs = []
  #         names = []
  #         sourceLang = Coreon.application.sourceLang()
  #         if not sourceLang? or sourceLang is 'none'
  #           sourceLang = 'en'
  #         names.push sourceLang
  #         if targetLang = Coreon.application.targetLang()
  #           names.push targetLang unless targetLang is 'none'
  #         for name in names
  #           langs.push
  #             name: name
  #             terms: ( terms[name] or [] )
  #               .map ( term ) ->
  #                 term.get 'value'
  #               .sort ( a, b ) ->
  #                 a.localeCompare b
  #         definition: concept.definition()
  #         langs: langs
  #
  #     @$('.concept-list-item').each ( index, tr ) =>
  #       concept = results[index]
  #       label = new Coreon.Views.Concepts.ConceptLabelView
  #         model: concept
  #       $tr = $ tr
  #       $tr.find('tr.label td').append label.render().$el
  #       @labels.push label
  #       broader = concept.broader()
  #       if broader.length > 1
  #         broader
  #           .sort ( a, b ) ->
  #             a.get('label').localeCompare b.get('label')
  #           .forEach ( parent ) =>
  #             @listenTo parent, 'change:label', @render
  #             @broader.push parent
  #       $els = broader.map ( parent ) =>
  #         label = new Coreon.Views.Concepts.ConceptLabelView
  #           model: parent
  #         @labels.push label
  #         label.render().$el
  #       $tr.find('tr.broader td').append $els...
  #   @

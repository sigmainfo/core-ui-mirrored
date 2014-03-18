#= require environment
#= require templates/panels/concepts/concept_list/terms

class Coreon.Views.Panels.Concepts.ConceptList.TermsView extends Backbone.View

  tagName: 'tbody'

  template: Coreon.Templates['panels/concepts/concept_list/terms']

  initialize: (attrs, options = {}) ->
    @app = options.app or Coreon.application

    @stopListening()

    @listenTo @model
            , 'change:terms'
            , @render

    @listenTo @app
            , 'change:langs'
            , @render

  render: ->
    terms = @model.termsByLang()
    langs = @app.get('langs')
    langs.push @app.lang() if langs.length is 0
    @$el.html @template langs: langs.map (lang) ->
      name: lang
      terms: (terms[lang] or []).map (term) ->
        term.get('value')
    @

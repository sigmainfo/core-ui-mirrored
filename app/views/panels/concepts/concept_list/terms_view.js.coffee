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
    langs = @app.get('langs').map (lang) ->
      name: lang
      terms: terms[lang] or []
    @$el.html @template langs: langs
    @

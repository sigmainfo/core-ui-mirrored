#= require environment
#= require views/composite_view
#= require views/terms/language_view

class Coreon.Views.Terms.TermsView extends Coreon.Views.CompositeView
  
  className: "terms"

  render: ->
    terms = _( @model.get("terms")?.models ).groupBy (term) ->
      term.get("lang")
    langs = (lang for lang of terms)
    for lang in langs
      @append new Coreon.Views.Terms.LanguageView
        lang: lang
        terms: terms[lang]
    super

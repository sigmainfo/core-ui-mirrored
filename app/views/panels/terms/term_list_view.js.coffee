#= require environment
#= require templates/terms/term_list
#= require views/panels/terms/term_view
#= require views/panels/terms/edit_term_view

class Coreon.Views.Panels.Terms.TermListView extends Backbone.View

  className: 'terms'

  template: Coreon.Templates['terms/term_list']

  initialize: ->
    @editMode = false

  render: ->
    groupedTerms = @sortTermsByLang()
    @$el.html @template groupedTerms: groupedTerms, hasTermProperties: @hasTermProperties()
    for lang, terms of groupedTerms
      for term, index in terms
        termView = null
        if @editMode && @termToEdit is term.id
          termView = new Coreon.Views.Panels.Terms.EditTermView model: term
        else
          termView = new Coreon.Views.Panels.Terms.TermView model: term
        @$("section.language.#{lang} ul").append termView.render().$el
    @

  setEditMode: (@editMode, @termToEdit) ->

  hasTermProperties: ->
    _(_(@model).values()).flatten().some (term) -> term.properties().length > 0


  sortTermsByLang: ->
    sourceLang = Coreon.application.sourceLang()
    targetLang = Coreon.application.targetLang()
    langs = Coreon.application.langs()

    sortedTermsByLangArr = langs.map (lang) =>
        [ lang, @model[lang] or [] ]
      .filter (tuple) ->
        [lang, terms] = tuple
        terms.length > 0 or
        lang is sourceLang or
        lang is targetLang

    for lang, terms of @model
      sortedTermsByLangArr.push [lang, terms] unless lang in langs

    sortedTermsByLang = {}

    _(sortedTermsByLangArr).each (pair) ->
      sortedTermsByLang[pair[0]] = pair[1]

    sortedTermsByLang

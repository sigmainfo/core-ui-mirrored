#= require environment
#= require templates/terms/term_list
#= require templates/terms/new_term
#= require views/panels/terms/term_view
#= require views/panels/terms/edit_term_view
#= require models/term

class Coreon.Views.Panels.Terms.TermListView extends Backbone.View

  className: 'terms'

  template: Coreon.Templates['terms/term_list']

  events:
    "click .edit-term"                           : "toggleEditTerm"
    "click  form.term.update .submit .cancel"    : "toggleEditTerm"
    "submit form.term.create"                    : "createTerm"
    "click  .add-term"                           : "addTerm"
    "click  .properties-toggle"                  : "toggleProperties"
    "click  section:not(form *) > *:first-child" : "toggleSection"

  initialize: ->
    @editMode = false
    @termToEdit = no
    @termViews = {}

  render: ->
    view.remove() for view in @termViews
    @termViews = {}
    terms = @model.terms()
    termsByLang = @termsByLang(terms)
    groupedTerms = @sortTermsByLang(termsByLang)
    @$el.html @template groupedTerms: groupedTerms, hasTermProperties: @hasTermProperties()
    for lang, terms of groupedTerms
      for term, index in terms
        termView = @createTermView(term).render().$el
        @$("section.language.#{lang}>ul").append termView
    @

  createTermView: (term) ->
    @listenTo term, 'termChanged', =>
      @toggleEditTerm()
    termView = null
    if @editMode && @termToEdit is term.id
      termView = new Coreon.Views.Panels.Terms.EditTermView model: term, isEdit: true, concept: @concept
    else
      termView = new Coreon.Views.Panels.Terms.TermView model: term
    @termViews[term.id] = termView
    termView

  setEditMode: (@editMode) ->

  setEditTerm: (@termToEdit) ->

  setConcept: (@concept) ->

  toggleEditTerm: (evt) ->
    if evt?
      evt.preventDefault()
      term_id = $(evt.target).data("id")
      @termToEdit = if @termToEdit == term_id then no else term_id
    else
      @termToEdit = !@termToEdit
    @trigger 'termsChanged', @termToEdit

  hasTermProperties: ->
    @model.terms().some (term) -> term.properties().length > 0

  termsByLang: (terms) ->
    terms.reduce (grouped, term) ->
      lang = term.get('lang').toLowerCase()
      grouped[lang] ?= []
      grouped[lang].push term
      grouped
    , {}

  sortTermsByLang: (termsByLang) ->
    sourceLang = Coreon.application.sourceLang()
    targetLang = Coreon.application.targetLang()
    langs = Coreon.application.langs()

    sortedTermsByLangArr = langs.map (lang) =>
        [ lang, termsByLang[lang] or [] ]
      .filter (tuple) ->
        [lang, terms] = tuple
        terms.length > 0 or
        lang is sourceLang or
        lang is targetLang

    for lang, terms of termsByLang
      sortedTermsByLangArr.push [lang, terms] unless lang in langs

    sortedTermsByLang = {}

    _(sortedTermsByLangArr).each (pair) ->
      sortedTermsByLang[pair[0]] = pair[1]

    sortedTermsByLang

  addTerm: ->
    @termToEdit = no
    @trigger 'termToEditChanged', @termToEdit
    @render()
    @$el.children(".add").hide()
    term = new Coreon.Models.Term
    @termToEdit = term.id
    termView = @createTermView(term)
    @listenTo termView, 'created', =>
      @trigger 'termsChanged'
    markup = termView.render().$el
    @$('>.add').after markup

  toggleProperties: () ->
    target = @$(".properties")
    if @$(".properties.collapsed").length > 0
      target.removeClass "collapsed"
      target.children("div").not(".edit").slideDown()
      Coreon.application.repositorySettings('propertiesCollapsed', off)
    else
      target.addClass "collapsed"
      target.children("div").not(".edit").slideUp()
      Coreon.application.repositorySettings('propertiesCollapsed', on)

  toggleSection: (evt) ->
    target = $(evt.target)
    target.closest("section").toggleClass "collapsed"
    target.siblings().not(".edit").slideToggle()

  close: ->
    view.remove() for view in @termViews
    @remove()


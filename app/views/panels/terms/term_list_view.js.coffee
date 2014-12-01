#= require environment
#= require templates/terms/term_list
#= require templates/terms/new_term
#= require views/panels/terms/term_view
#= require views/panels/terms/edit_term_view
#= require models/term

class Coreon.Views.Panels.Terms.TermListView extends Backbone.View

  className: 'terms'

  template: Coreon.Templates['terms/term_list']
  term:     Coreon.Templates["terms/new_term"]

  events:
    "click .edit-term"                        : "toggleEditTerm"
    "click  form.term.update .submit .cancel" : "toggleEditTerm"
    "submit form.term.create"                 : "createTerm"
    "click  .add-term"                        : "addTerm"

  initialize: ->
    @editMode = false
    @termToEdit = no
    @termViews = {}

  render: ->
    terms = @model.terms()
    termsByLang = @termsByLang(terms)
    groupedTerms = @sortTermsByLang(termsByLang)
    @$el.html @template groupedTerms: groupedTerms, hasTermProperties: @hasTermProperties()
    for lang, terms of groupedTerms
      for term, index in terms
        termView = @createTermView(term).render().$el
        @$("section.language.#{lang} ul").append termView
    @

  createTermView: (term) ->
    @listenTo term, 'sync', =>
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
    @$el.children(".add").hide()
    term = new Coreon.Models.Term
    @termToEdit = term.id
    termView = @createTermView(term)
    @listenTo termView, 'created', =>
      @trigger 'termsChanged'
    markup = termView.render().$el
    @$('.add').after markup

  # createTerm: (evt) ->
  #   evt.preventDefault()
  #   target = $ evt.target
  #   data = target.serializeJSON().term or {}
  #   data.concept_id = @model.id
  #   data.properties = @termProperties[0].serializeArray()

  #   term = new Coreon.Models.Term data
  #   request = term.save null, wait: yes
  #   request.done =>
  #     Coreon.Models.Notification.info I18n.t("notifications.term.created", value: term.get("value"))
  #     @model.terms().add term
  #     @toggleEditTerm()
  #   request.fail =>
  #     @$("form.term.create").replaceWith @term term: term
  #     @newTermPropertiesView(term)

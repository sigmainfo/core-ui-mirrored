#= require environment
#= require helpers/render
#= require helpers/can
#= require helpers/form_for
#= require helpers/input
#= require helpers/action_for
#= require templates/concepts/concept
#= require templates/concepts/_caption
#= require templates/concepts/_info
#= require templates/concepts/_edit_properties
#= require templates/concepts/_properties
#= require templates/concepts/_term
#= require templates/terms/new_term
#= require templates/properties/new_property
#= require views/concepts/shared/broader_and_narrower_view
#= require collections/clips
#= require collections/hits
#= require models/broader_and_narrower_form
#= require models/term
#= require models/notification
#= require modules/helpers
#= require modules/nested_fields_for
#= require modules/confirmation
#= require jquery.serializeJSON
#= require modules/draggable
#= require views/terms/terms_view

class Coreon.Views.Concepts.ConceptView extends Backbone.View

  Coreon.Modules.extend @, Coreon.Modules.NestedFieldsFor
  Coreon.Modules.include @, Coreon.Modules.Confirmation
  Coreon.Modules.include @, Coreon.Modules.Draggable

  className: 'concept'
  editProperties: no
  editTerm: no

  template: Coreon.Templates["concepts/concept"]
  term:     Coreon.Templates["terms/new_term"]

  @nestedFieldsFor "properties", name: "property"

  events:
    "click  .concept-to-clipboard.add"           : "addConceptToClipboard"
    "click  .concept-to-clipboard.remove"        : "removeConceptFromClipboard"
    "click  .toggle-edit-mode"                   : "toggleEditMode"
    "click  *:not(.terms) .edit-properties"      : "toggleEditConceptProperties"
    "click  .system-info-toggle"                 : "toggleInfo"
    "click  section:not(form *) > *:first-child" : "toggleSection"
    "click  .properties .index li"               : "selectProperty"
    "click  .add-property"                       : "addProperty"
    "click  .remove-property"                    : "removeProperty"
    "click  .add-term"                           : "addTerm"
    "click  .remove-term"                        : "removeTerm"
    "submit form.concept.update"                 : "updateConceptProperties"
    "submit form.term.create"                    : "createTerm"
    "submit form.term.update"                    : "updateTerm"
    "click  form a.cancel:not(.disabled)"        : "cancelForm"
    "click  form a.reset:not(.disabled)"         : "reset"
    "click  .edit-term"                          : "toggleEditTerm"
    "click  .delete-concept"                     : "delete"
    "click  form.concept.update .submit .cancel" : "toggleEditConceptProperties"
    "click  form.term.update .submit .cancel"    : "toggleEditTerm"

  initialize: ->
    @stopListening()
    @listenTo @model, "change", @render
    @listenTo Coreon.application, 'change:editing', @render

    if settings = Coreon.application?.repositorySettings()
      @listenTo settings, 'change:sourceLanguage change:targetLanguage', @render, @

    @listenTo Coreon.Collections.Clips.collection(), "add remove reset", @setClipboardButton
    @subviews = []
    @

  render: (model, options = {}) ->
    return @ if options.internal
    subview.remove() for subview in @subviews
    @subviews = []

    termsByLang = @model.termsByLang()
    sourceLang = Coreon.application.sourceLang()
    targetLang = Coreon.application.targetLang()
    langs = Coreon.application.langs()

    sortedTermsByLang = langs
      .map (lang) ->
        [ lang, termsByLang[lang] or [] ]
      .filter (tuple) ->
        [lang, terms] = tuple
        terms.length > 0 or
        lang is sourceLang or
        lang is targetLang

    for lang, terms of termsByLang
      sortedTermsByLang.push [lang, terms] unless lang in langs

    hasTermProperties = @model.terms().hasProperties()
    editing = Coreon.application.get 'editing'

    @$el.toggleClass 'edit', editing
    @$el.toggleClass 'show', not editing

    @$el.html @template
      concept: @model
      langs: sortedTermsByLang
      hasTermProperties: hasTermProperties
      editing: editing
      editProperties: @editProperties
      editTerm: @editTerm

    broaderAndNarrower = new Coreon.Views.Concepts.Shared.BroaderAndNarrowerView
      model: @model
    @$el.children(".concept-head").after broaderAndNarrower.render().$el
    @subviews.push broaderAndNarrower

    unless editing
      terms = new Coreon.Views.Terms.TermsView model: @model.terms()
      @$el.append terms.render().$el
      @subviews.push terms

    @$('.system-info').hide()

    @draggableOn(el) for el in @$('[data-drag-ident]')

    if Coreon.Collections.Clips.collection().get(@model)
      @$(".concept-to-clipboard.add").hide()
      @$(".concept-to-clipboard.remove").show()
    else
      @$(".concept-to-clipboard.remove").hide()
      @$(".concept-to-clipboard.add").show()
    @

  toggleInfo: (evt) ->
    @$(".system-info")
      .slideToggle()

  toggleSection: (evt) ->
    target = $(evt.target)
    target.closest("section").toggleClass "collapsed"
    target.siblings().not(".edit").slideToggle()

  selectProperty: (evt) ->
    target = $(evt.target)
    container = target.closest "td"
    container.find("li.selected").removeClass "selected"
    container.find(".values > li").eq(target.data "index").add(target)
      .addClass "selected"

  toggleEditMode: ->
    Coreon.application.set 'editing',
      not Coreon.application.get 'editing'

  toggleEditConceptProperties: (evt)->
    evt.preventDefault() if evt?
    @editProperties = !@editProperties
    @render()

  toggleEditTerm: (evt) ->
    if evt?
      evt.preventDefault()
      term_id = $(evt.target).data("id")
      @editTerm = if @editTerm == term_id then no else term_id
    else
      @editTerm = !@editTerm

    @render()

  addTerm: ->
    terms = @$(".terms")
    terms.children(".add").hide()
    @$('.terms .add').after @term term: new Coreon.Models.Term

  saveConceptProperties: (attrs) ->
    request = @model.save attrs, wait: yes, attrs: concept: attrs
    request.done => @toggleEditConceptProperties()
    request.fail => @model.set attrs

  updateConceptProperties: (evt) ->
    evt.preventDefault()
    form = $ evt.target
    data = form.serializeJSON().concept or {}
    attrs = {}
    attrs.properties = if data.properties?
      property for property in data.properties when property?
    else []
    trigger = form.find('[type=submit]')
    elements_to_delete = form.find(".property.delete")

    if elements_to_delete.length > 0
      @confirm
        trigger: trigger
        message: I18n.t "concept.confirm_update", count: elements_to_delete.length
        action: => @saveConceptProperties attrs
    else
      @saveConceptProperties attrs

  updateTerm: (evt) ->
    evt.preventDefault()
    form = $ evt.target
    data = form.serializeJSON()?.term or {}
    data.id = form.find("input[name=id]").val()
    data.properties = if data.properties?
      property for property in data.properties when property?
    else []

    trigger = form.find('[type=submit]')
    elements_to_delete = form.find(".property.delete")
    model = @model.terms().get data.id

    if elements_to_delete.length > 0
      @confirm
        trigger: trigger
        message: I18n.t "term.confirm_update", count: elements_to_delete.length
        action: =>
          @saveTerm(model, data)
    else
      @saveTerm(model, data)

  saveTerm: (model, attrs) ->
    request = model.save attrs, wait: yes, attrs: term: attrs
    request.done =>
      Coreon.Models.Notification.info I18n.t("notifications.term.saved", value: model.get "value")
      @toggleEditTerm()
    request.fail =>
      model.set attrs
      @render()

  createTerm: (evt) ->
    evt.preventDefault()
    target = $ evt.target
    data = target.serializeJSON().term or {}
    data.concept_id = @model.id
    data.properties = if data.properties?
      property for property in data.properties when property?
    else []

    term = new Coreon.Models.Term data
    request = term.save null, wait: yes
    request.done =>
      Coreon.Models.Notification.info I18n.t("notifications.term.created", value: term.get("value"))
      @model.terms().add term
      @toggleEditTerm()
    request.fail =>
      @$("form.term.create").replaceWith @term term: term

  cancelForm: (evt) ->
    evt.preventDefault()
    @model.revert()
    @model.remoteError = null
    form = $(evt.target).closest "form"
    form.siblings(".edit").show()
    form.remove()

  reset: (evt) ->
    evt.preventDefault()
    @model.revert()
    @model.remoteError = null
    @render()

  removeTerm: (evt) =>
    trigger = $ evt.target
    container = trigger.closest ".term"
    model = @model.terms().get trigger.data "id"
    @confirm
      trigger: trigger
      container: container
      message: I18n.t "term.confirm_delete"
      action: =>
        value = model.get "value"
        model.destroy()
        Coreon.Models.Notification.info I18n.t("notifications.term.deleted", value:value)
        @render()

  delete: (evt) ->
    trigger = $ evt.target
    label = @model.get "label"
    @confirm
      trigger: trigger
      container: trigger.closest ".concept"
      message: I18n.t "concept.confirm_delete"
      action: =>
        Coreon.Collections.Hits.collection().reset []
        @model.destroy()
        Coreon.Models.Notification.info I18n.t("notifications.concept.deleted", label: label)
        Backbone.history.navigate "/#{Coreon.application.repository().id}", trigger: true

  addConceptToClipboard: ->
    Coreon.Collections.Clips.collection().add @model

  removeConceptFromClipboard: ->
    Coreon.Collections.Clips.collection().remove @model

  setClipboardButton: ->
    if Coreon.Collections.Clips.collection().get @model
      @$(".concept-to-clipboard.add").hide()
      @$(".concept-to-clipboard.remove").show()
    else
      @$(".concept-to-clipboard.remove").hide()
      @$(".concept-to-clipboard.add").show()


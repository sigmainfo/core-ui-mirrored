#= require environment
#= require helpers/render
#= require helpers/can
#= require helpers/form_for
#= require helpers/input
#= require helpers/action_for
#= require templates/concepts/concept
#= require templates/concepts/caption
#= require templates/shared/info
#= require templates/concepts/_properties
#= require templates/concepts/_edit_properties
#= require templates/concepts/_term
#= require templates/terms/new_term
#= require templates/properties/new_property
#= require views/concepts/shared/broader_and_narrower_view
#= require views/terms/terms_view
#= require views/terms/edit_terms_view
#= require views/properties/properties_view
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


class Coreon.Views.Concepts.ConceptView extends Backbone.View

  # TODO 140522 [tc] deprecate module helpers in favor of using Underscore
  Coreon.Modules.extend @, Coreon.Modules.NestedFieldsFor
  Coreon.Modules.include @, Coreon.Modules.Confirmation
  Coreon.Modules.include @, Coreon.Modules.Draggable

  className: 'concept'
  editProperties: no
  editTerm: no

  term: Coreon.Templates['terms/new_term']

  @nestedFieldsFor "properties", name: "property"

  events:
    "click  .add-to-clipboard"                   : "addConceptToClipboard"
    "click  .remove-from-clipboard"              : "removeConceptFromClipboard"
    "click  .toggle-edit-mode"                   : "toggleEditMode"
    "click  *:not(.terms) .edit-properties"      : "toggleEditConceptProperties"
    "click  .toggle-system-info"                 : "toggleSystemInfo"
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

  initialize: (options = {}) ->
    @app = options.app or Coreon.application
    @template = Coreon.Templates['concepts/concept']

    @stopListening()

    @listenTo @model, 'change', @render
    @listenTo @app, 'change:editing', @render

    settings = @app.repositorySettings()
    @listenTo settings, 'change:sourceLanguage change:targetLanguage', @render

    clips = Coreon.Collections.Clips.collection()
    @listenTo clips, 'add remove reset', @setClipboardButton

    @subviews = []
    @

  render: (model, options = {}) ->
    return @ if options.internal
    subview.remove() for subview in @subviews
    @subviews = []

    conceptData = @conceptData @model
    termGroups = @termGroups @model, @app
    hasTermProperties = @model.terms().hasProperties() #TODO 140508 move this back here?
    editing = @editing()

    @$el.html @template
      model: @model #TODO 140508 [tc] remove direct reference to model
      concept: conceptData
      langs: termGroups #TODO 140508 [tc] rename to terms
      hasTermProperties: hasTermProperties
      editing: editing
      editProperties: @editProperties
      editTerm: @editTerm

    @$el.toggleClass 'edit', editing
    @$el.toggleClass 'show', not editing

    #TODO 140507 [tc] move view one level up, i.e. skip shared
    broaderAndNarrower = new Coreon.Views.Concepts.Shared.BroaderAndNarrowerView
      model: @model
    @$el.children(".concept-head").after broaderAndNarrower.render().$el
    @subviews.push broaderAndNarrower

    unless @editProperties
      if @model.hasProperties()
        properties = new Backbone.Collection @model.publicProperties()
        propertiesView = new Coreon.Views.Properties.PropertiesView
          model: properties
        @$('.broader-and-narrower').after propertiesView.render().$el
        @subviews.push propertiesView

    termsViewType = if editing then 'EditTermsView' else 'TermsView'
    termsView = new Coreon.Views.Terms[termsViewType] model: @model.terms()
    @$el.append termsView.render().$el
    @subviews.push termsView

    @$('.system-info').hide()

    @draggableOn(el) for el in @$('[data-drag-ident]')

    @setClipboardButton()
    @

  conceptData: ->
    id: @model.id
    label: @model.get('label')
    info: @model.info()

  termGroups: ->
    termsByLang = @model.termsByLang()
    sourceLang = @app.sourceLang()
    targetLang = @app.targetLang()
    langs = @app.langs()

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

    sortedTermsByLang

  editing: ->
    if Coreon.Helpers.can('manage') and @app.get('editing') then on else off

  toggleSystemInfo: (evt) ->
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
    @app.set 'editing',
      not @app.get 'editing'

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
        Backbone.history.navigate "/#{@app.repository().id}", trigger: true

  addConceptToClipboard: ->
    Coreon.Collections.Clips.collection().add @model

  removeConceptFromClipboard: ->
    Coreon.Collections.Clips.collection().remove @model

  setClipboardButton: ->
    if Coreon.Collections.Clips.collection().get @model
      @$('.add-to-clipboard').hide()
      @$('.remove-from-clipboard').show()
    else
      @$('.add-to-clipboard').show()
      @$('.remove-from-clipboard').hide()

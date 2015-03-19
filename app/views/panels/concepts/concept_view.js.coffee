#= require environment
#= require lib/sort
#= require helpers/render
#= require helpers/can
#= require helpers/form_for
#= require helpers/input
#= require helpers/select_field
#= require helpers/text_field
#= require helpers/text_area_field
#= require helpers/check_box_field
#= require helpers/multi_select_field
#= require helpers/graph_uri
#= require modules/assets
#= require templates/panels/concepts/concept
#= require templates/concepts/_caption
#= require templates/concepts/_info
#= require templates/concepts/_properties
#= require templates/concepts/_edit_properties
#= require templates/properties/new_property
#= require templates/properties/value
#= require views/concepts/shared/broader_and_narrower_view
#= require views/concepts/shared/associative_relations_view
#= require views/panels/terms/term_list_view
#= require views/widgets/asset_view
#= require collections/clips
#= require collections/hits
#= require models/broader_and_narrower_form
#= require models/term
#= require models/notification
#= require modules/helpers
#= require modules/nested_fields_for
#= require modules/confirmation
#= require modules/prompt
#= require jquery.serializeJSON
#= require modules/draggable
#= require models/repository_settings

class Coreon.Views.Panels.Concepts.ConceptView extends Backbone.View

  Coreon.Modules.extend @, Coreon.Modules.NestedFieldsFor
  Coreon.Modules.include @, Coreon.Modules.Confirmation
  Coreon.Modules.include @, Coreon.Modules.Draggable
  Coreon.Modules.include @, Coreon.Modules.Prompt
  Coreon.Modules.include @, Coreon.Modules.Assets

  className: 'concept'
  editProperties: no
  termToEdit: no

  template: Coreon.Templates["panels/concepts/concept"]

  @nestedFieldsFor "properties", name: "property"

  events:
    "click  .concept-to-clipboard.add"             : "addConceptToClipboard"
    "click  .concept-to-clipboard.remove"          : "removeConceptFromClipboard"
    "click  .edit-concept"                         : "toggleEditMode"
    "click  *:not(.terms) .edit-properties"        : "toggleEditConceptProperties"
    "click  .system-info-toggle"                   : "toggleInfo"
    "click  .properties .index li"                 : "selectProperty"
    "click  .properties .asset figure"             : "launchAssetViewer"
    "submit form.concept.update"                   : "updateConceptProperties"
    "click  form a.cancel:not(.disabled)"          : "cancelForm"
    "click  .delete-concept"                       : "delete"
    "click  form.concept.update .submit .cancel"   : "toggleEditConceptProperties"
    "click  form a.reset:not(.disabled)"           : "reset"
    "click  > section:not(form *) > *:first-child" : "toggleSection"

  initialize: ->
    @stopListening()
    @listenTo @model, "change", @render
    @listenTo Coreon.application, 'change:editing', @render

    if settings = Coreon.application?.repositorySettings()
      @listenTo settings, 'change:sourceLanguage change:targetLanguage', @render, @

    @listenTo Coreon.Collections.Clips.collection(), "add remove reset", @setClipboardButton
    @

  render: (model, options = {}) ->
    return @ if options.internal

    editing = Coreon.application.get 'editing'

    @$el.toggleClass 'edit', editing
    @$el.toggleClass 'show', not editing

    @$el.html @template
      concept: @model
      editing: editing
      editProperties: @editProperties

    broaderAndNarrower = new Coreon.Views.Concepts.Shared.BroaderAndNarrowerView
      model: @model

    associativeRelations = new Coreon.Views.Concepts.Shared.AssociativeRelationsView
      collection: @model.associativeRelations()
      editing: editing
      concept: @model

    @conceptProperties?.remove()
    @conceptProperties = new Coreon.Views.Properties.EditPropertiesView
      collection: @model.propertiesWithDefaults(includeUndefined: true)
      optionalProperties: Coreon.Models.RepositorySettings.optionalPropertiesFor('concept')
      isEdit: true
      collapsed: true

    @termListView.close() if @termListView
    @termListView = new Coreon.Views.Panels.Terms.TermListView model: @model
    @termListView.setEditMode(editing)
    @termListView.setEditTerm(@termToEdit)
    @termListView.setConcept(@model)
    @listenTo @termListView, 'termsChanged', (termToEdit) =>
      @termToEdit = termToEdit
      @model.fetch =>
        success: =>
          @render()
    @listenTo @termListView, 'termToEditChanged', (termToEdit) =>
      @termToEdit = termToEdit

    @$el.children(".concept-head").after associativeRelations.render().$el
    @$el.children(".concept-head").after broaderAndNarrower.render().$el
    @$el.append @termListView.render().$el
    @$el.find("form.concept .submit").before @conceptProperties.render().$el

    @refreshPropertiesValidation @conceptProperties

    @draggableOn(el) for el in @$('[data-drag-ident]')

    if Coreon.Collections.Clips.collection().get(@model)
      @$(".concept-to-clipboard.add").hide()
      @$(".concept-to-clipboard.remove").show()
    else
      @$(".concept-to-clipboard.remove").hide()
      @$(".concept-to-clipboard.add").show()
    @

  refreshPropertiesValidation: (subView) ->
    subView.$el.closest('form').find(".submit button[type=submit]").prop('disabled', !subView.isValid())
    @listenTo subView, 'updateValid', ->
      subView.$el.closest('form').find(".submit button[type=submit]").prop('disabled', !subView.isValid())

  toggleInfo: (evt) ->
    @$(".system-info")
      .slideToggle()

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

  toggleSection: (evt) ->
    target = @$el.find(evt.target)
    target.closest("section").toggleClass "collapsed"
    target.siblings().not(".edit").slideToggle()


  saveConceptProperties: (attrs, assets) ->
    view = @
    request = @model.save attrs, silent: yes, wait: yes, attrs: concept: attrs

    request.done =>
      $.when(
        view.saveAssets('concept', view.model, assets)
      ).done =>
        view.model.fetch
          success: =>
            @toggleEditConceptProperties()
    request.fail => @model.set attrs

  updateConceptProperties: (evt) ->
    evt.preventDefault()
    form = $ evt.target
    data = form.serializeJSON().concept or {}
    attrs = {}
    attrs.properties = @conceptProperties.serializeArray()
    trigger = form.find('[type=submit]')
    elements_to_delete = @conceptProperties.countDeleted()
    assets = @conceptProperties.serializeAssetsArray()

    if elements_to_delete > 0
      @confirm
        trigger: trigger
        message: I18n.t "concept.confirm_update", count: elements_to_delete
        action: => @saveConceptProperties attrs, assets
        restore: => @$el.trigger('restore', [form])
    else
      @saveConceptProperties attrs, assets

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

  launchAssetViewer: (event) ->
    figure = $(event.target).closest('figure')
    imageClicked = figure.children('img')
    if imageClicked.attr('data-type') is 'image'
      imageIndex = imageClicked.attr('data-index') || 0
      images = imageClicked.closest("tr.asset td > ul.values > li.selected").find('img[data-type="image"]').map ->
        { uri: $(@).data('uri'), preview_uri: $(@).data('previewUri'), info: $(@).data('info'), index: $(@).data('index') }
      collection = new Backbone.Collection images.get()
      assetView = new Coreon.Views.Widgets.AssetView
        collection: collection
        current: imageIndex
      assetView.on 'remove', @closeAssetViewer
      @prompt assetView
    else
      a = $("<a>")
        .attr("href", imageClicked.attr('data-uri'))
        .attr("download", imageClicked.attr('data-caption'))
        .appendTo("body");
      a[0].click()
      #a.remove()

  closeAssetViewer: ->
    @unprompt



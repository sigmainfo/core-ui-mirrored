#= require environment
#= require views/panels/panel_view
#= require helpers/titlebar
#= require templates/panels/concepts
#= require views/panels/concepts/repository_view
#= require views/panels/concepts/concept_list_view
#= require views/panels/concepts/concept_view
#= require views/panels/concepts/new_concept_view

class Coreon.Views.Panels.ConceptsPanel extends Coreon.Views.Panels.PanelView

  id: 'coreon-concepts'

  layout: Coreon.Templates['panels/concepts']

  current: null

  events:
    'click .maximize'               : 'disableEditConcept'

  initialize: ->
    super
    @$el.html @layout()

    @switchView()

    @listenTo @model
            , 'change:selection change:scope change:repository'
            , @switchView

  switchView: ->
    @currentView?.remove()

    @currentView =
      if selection = @model.get 'selection'
        if @model.get('scope') is 'index'
          new Coreon.Views.Panels.Concepts.ConceptListView
            model: selection
        else
          model = selection.first()
          if model.isNew()
            new Coreon.Views.Panels.Concepts.NewConceptView
              model: model
          else
            new Coreon.Views.Panels.Concepts.ConceptView
              model: model
      else
        if repository = @model.get('repository')
          new Coreon.Views.Panels.Concepts.RepositoryView
            model: repository
        else
          null

    @$('.content').append @currentView?.render().$el

  render: ->
    @currentView?.render()
    @

  disableEditConcept: ->
    $("body").removeClass('edit_mode');
    $('.edit-map').removeClass('edit_pressed');
    $('.edit-map').hide();
    $('.submit_concept').hide();
    window.edit_mode_selected = false
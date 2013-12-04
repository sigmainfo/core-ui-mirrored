#= require environment
#= require templates/widgets/term_list
#= require templates/widgets/term_list_info
#= require templates/widgets/term_list_items
#= require jquery.ui.resizable
#= require models/concept

defaults =
  size: [320, 120]

class Coreon.Views.Widgets.TermListView extends Backbone.View

  id: 'coreon-term-list'

  className: 'widget'

  template: Coreon.Templates['widgets/term_list']
  info    : Coreon.Templates['widgets/term_list_info']
  terms   : Coreon.Templates['widgets/term_list_items']

  initialize: ->
    @stopListening()
    @$el.resizable 'destroy' if @$el.hasClass 'ui-resizable'

    @$el.html @template()
    @$el.resizable
      handles: 's'
      minHeight: 80
      resize: (event, ui) => @resize ui.size
    @resize Coreon.application.repositorySettings('termList')

    @listenTo Coreon.application.repositorySettings(), 'change:sourceLanguage', @render
    @listenTo @model, 'reset', @render

  render: ->
    tbody = @$ 'tbody'
    sourceLanguage = Coreon.application.repositorySettings('sourceLanguage')
    noSourceLanguage = _.isEmpty(sourceLanguage) or sourceLanguage is 'none'
    if noSourceLanguage
      tbody.html @info()
    else
      terms = @model.map( (term) ->
        value: term.get 'value'
        path: new Coreon.Models.Concept(id: term.get 'concept_id').path()
      )
      .sort( (a, b) ->
        a.value.localeCompare b.value
      )
      tbody.html @terms(terms: terms)
    @

  resize: (size) ->
    size.height ?= defaults.size[1]
    @$el.height size.height
    @saveLayout height: size.height

  saveLayout = (layout) ->
    Coreon.application.repositorySettings('termList', layout)

  saveLayout: _.debounce saveLayout, 500

#= require environment
#= require templates/widgets/term_list
#= require templates/widgets/term_list_info
#= require templates/widgets/term_list_items
#= require templates/widgets/term_list_placeholder
#= require jquery.ui.resizable
#= require models/concept

defaults =
  size: [320, 120]

class Coreon.Views.Widgets.TermListView extends Backbone.View

  id: 'coreon-term-list'

  className: 'widget'

  template    : Coreon.Templates['widgets/term_list']
  info        : Coreon.Templates['widgets/term_list_info']
  terms       : Coreon.Templates['widgets/term_list_items']
  placeholder : Coreon.Templates['widgets/term_list_placeholder']

  events:
    'click .toggle-scope' : 'toggleScope'

  delegateEvents: ->
    super
    @$('table').scroll _.bind @topUp, @

  initialize: ->
    @$el.resizable 'destroy' if @$el.hasClass 'ui-resizable'

    @$el.html @template()

    @$el.resizable
      handles: 's'
      minHeight: 80
      resize: (event, ui) => @resize ui.size
    @resize Coreon.application.repositorySettings('termList')

    @stopListening()

    @listenTo @model
            , 'reset'
            , @render

    @listenTo @model
            , 'append'
            , @appendItems

    @listenTo @model
            , 'change:loadingNext'
            , @updateLoadingState

  render: ->
    @$( 'table' ).scrollTop 0
    @$( 'tbody' ).html if @model.has('source')
      @terms
        terms: @data @model.terms
    else
      @info()
    @

  appendItems: ( response ) ->
    list = @$( 'tbody' )
    terms = new Coreon.Collections.Terms response
    list.append @terms terms: @data terms
    @topUp()

  data: ( terms ) ->
    terms.map ( term ) =>
      value: term.get 'value'
      path:  term.conceptPath()
      hit:   @model.hits.get( term )?
      id:    term.id

  resize: (size) ->
    size.height ?= defaults.size[1]
    @$el.height size.height
    @saveLayout height: size.height

  saveLayout = (layout) ->
    Coreon.application.repositorySettings('termList', layout)

  saveLayout: _.debounce saveLayout, 500

  topUp: ->
    if @model.hasNext() and not @model.get 'loadingNext'
      if @closeToTail()
        @model.next()

  closeToTail: ->
    outer = @$ 'table'
    inner = @$ 'tbody'
    max = inner.outerHeight() - outer.innerHeight()
    delta = max - outer.scrollTop()
    threshold = outer.innerHeight() * 0.8
    delta < threshold

  updateLoadingState: ->
    list = @$ 'tbody'
    if @model.get 'loadingNext'
      if list.find( '.placeholder.next' ).length is 0
        list.append @placeholder className: 'next'
    else
      list.find( '.placeholder.next' ).remove()

  toggleScope: ->
    oldScope = @model.get 'scope'
    newScope = if oldScope is 'all' then 'hits' else 'all'
    @model.set 'scope', newScope

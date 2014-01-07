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

  initialize: ->
    @stopListening()
    @$el.resizable 'destroy' if @$el.hasClass 'ui-resizable'

    @$el.html @template()

    @$el.resizable
      handles: 's'
      minHeight: 80
      resize: (event, ui) => @resize ui.size
    @resize Coreon.application.repositorySettings('termList')


    @listenTo @model, 'update', @render

  delegateEvents: ->
    @$('table').scroll _.bind @topUp, @

  render: ->
    @$('tbody').html if @model.has('source')
      @terms
        terms: @data @model.terms
    else
      @info()
    @

  appendItems: ( terms ) ->
    list = @$( 'tbody' )
    list.find( '.placeholder' ).remove()
    list.append @terms terms: @data terms
    @topUp()

  data: ( terms ) ->
    terms.map ( term ) =>
      value: term.get 'value'
      path:  term.conceptPath()
      hit:   @model.hits.get( term )?

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
        @$( 'tbody' ).append @placeholder()
        @model.next().then _.bind @appendItems, @

  closeToTail: ->
    outer = @$ 'table'
    inner = @$ 'tbody'
    max = inner.outerHeight() - outer.innerHeight()
    delta = max - outer.scrollTop()
    threshold = outer.innerHeight() * 0.8
    delta < threshold

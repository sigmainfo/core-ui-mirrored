#= require environment
#= require views/panels/panel_view
#= require helpers/titlebar
#= require templates/panels/term_list
#= require templates/panels/term_list/title
#= require templates/panels/term_list/info
#= require templates/panels/term_list/items
#= require templates/panels/term_list/translations
#= require templates/panels/term_list/placeholder
#= require models/concept

defaults =
  size: [320, 120]

class Coreon.Views.Panels.TermListPanel extends Coreon.Views.Panels.PanelView

  id: 'coreon-term-list'

  template    : Coreon.Templates['panels/term_list']
  title       : Coreon.Templates['panels/term_list/title']
  info        : Coreon.Templates['panels/term_list/info']
  terms       : Coreon.Templates['panels/term_list/items']
  targetTerms : Coreon.Templates['panels/term_list/translations']
  placeholder : Coreon.Templates['panels/term_list/placeholder']

  events:
    'click .toggle-scope' : 'toggleScope'
    'click tr.term'       : 'openConcept'

  delegateEvents: ->
    super
    @$('table').scroll _.bind @topUp, @

  initialize: ->
    super

    title = @title
      source: @model.get( 'source' )?.toUpperCase()
      target: @model.get( 'target' )?.toUpperCase()

    @$el.html @template
      title: title
      actions: [ 'panels.term_list.toggle_scope' ]

    @listenTo @model
            , 'reset'
            , @render

    @listenTo @model
            , 'append'
            , @appendItems

    @listenTo @model
            , 'prepend'
            , @prependItems

    @listenTo @model
            , 'change:loadingNext change:loadingPrev'
            , @updateLoadingState

    @listenTo @model
            , 'change:target'
            , @updateTargetLang

    @listenTo @model
            , 'change:source change:target'
            , @updateLangs

    @listenTo @model
            , 'updateTargetTerms'
            , @updateTranslations

  render: ->
    @$( 'table' ).scrollTop 0
    @$( 'tbody' ).html if @model.has( 'source' )
      @terms
        terms: @data @model.terms
    else
      @info()
    @

  appendItems: ( terms ) ->
    list = @$( 'tbody' )
    list.append @terms terms: @data terms
    @topUp()

  prependItems: ( terms ) ->
    list = @$( 'tbody' )
    outer = $ 'table'
    if anchor = @anchor()
      before = anchor.position().top
    list.prepend @terms terms: @data terms
    if before
      after = anchor.position().top
      outer.scrollTop( outer.scrollTop() + after - before )
    @topUp()

  data: ( terms ) ->
    terms.map ( term ) =>
      value: term.get 'value'
      path:  term.conceptPath()
      hit:   @model.hits.get( term )?
      id:    term.id
      translations: @translations( term )

  translations: ( term ) ->
    if @model.has( 'target' )
      concept = Coreon.Models.Concept.find term.get( 'concept_id' )
      value = concept.terms().lang( @model.get 'target' )[0]?.get 'value'
      @targetTerms translation: value
    else
      null

  topUp: ->
    if @model.hasNext() and not @model.get 'loadingNext'
      @model.next() if @closeToTail()

    if @model.terms.length > 0
      if @model.hasPrev() and not @model.get 'loadingPrev'
        @model.prev() if @closeToHead()

  threshold: ->
    outer = @$ 'table'
    outer.innerHeight() * 0.8

  closeToTail: ->
    outer = @$ 'table'
    inner = @$ 'tbody'
    max = inner.outerHeight() - outer.innerHeight()
    offset = max - outer.scrollTop()
    offset < @threshold()

  closeToHead: ->
    outer = @$ 'table'
    inner = @$ 'tbody'
    offset = outer.scrollTop()
    offset < @threshold()

  updateLoadingState: ->
    list = @$ 'tbody'

    if @model.get 'loadingNext'
      if list.find( '.placeholder.next' ).length is 0
        list.append @placeholder className: 'next'
        placeholder = list.find( '.placeholder.next' )
        placeholder.hide().fadeIn()
    else
      list.find( '.placeholder.next' ).remove()

    outer = list.parent()

    if @model.get 'loadingPrev'
      if list.find( '.placeholder.prev' ).length is 0
        list.prepend @placeholder className: 'prev'
        placeholder = list.find( '.placeholder.prev' )
        placeholder.hide().fadeIn()
        outer.scrollTop outer.scrollTop() + placeholder.outerHeight( yes )
    else
      placeholder = list.find( '.placeholder.prev' )
      if placeholder.length > 0
        outer.scrollTop outer.scrollTop() - placeholder.outerHeight( yes )
        placeholder.remove()

  toggleScope: ->
    switch @model.get 'scope'
      when 'all'  then @limitScope()
      when 'hits' then @expandScope()

  limitScope: ->
    anchorHit = @anchorHit()
    @model.set 'scope', 'hits'
    if anchorHit?
      anchor = @$ "tr.term.hit[data-id='#{anchorHit.id}']"
      offset = anchor.position().top
      @$( 'table' ).scrollTop( offset - 7 )

  expandScope: ->
    anchorId = @anchor()?.data( 'id' ) or null
    @model.set 'scope', 'all', silent: yes
    @model.clearTerms()
    @model.next anchorId

  anchor: ->
    anchor = null
    offset = @$( 'table' ).scrollTop()
    @$( 'tr.term' ).each ->
      tr = $( @ )
      if tr.position().top >= offset
        anchor = tr
        return false
    anchor

  anchorHit: ->
    if anchor = @anchor()
      hits  = @model.hits
      terms = @model.terms
      term  = terms.get anchor.data( 'id' )
      if hit = hits.get term
        anchorHit = hit
      else if source = @model.get( 'source' )
        sortKey = term.get 'sort_key'
        hitsByLang = hits.lang( source )
        anchorHit = _.find hitsByLang, ( hit ) ->
          hit.get( 'sort_key' ) >= sortKey
        anchorHit or= _.last( hitsByLang )
    anchorHit or null

  updateTargetLang: ->
    rows = @$( 'tr.term' )
    if @model.has 'target'

      if rows.first().find( 'td.target' ).length is 0
        rows.append( '<td class="target">' )

      rows.each ( index, el ) =>
        row = $( el )
        term = @model.terms.get( row.data 'id' )
        row.find( 'td.target' ).html @translations( term )

    else
      rows.find( 'td.target' ).remove()

  updateTranslations: ( targetTerms ) ->
    first = targetTerms[0]
    conceptId = first.get 'concept_id'
    concept = Coreon.Models.Concept.find conceptId
    translations = @translations( first )
    sourceTerms = concept.terms().lang( @model.get 'source' )
    sourceTerms.forEach ( term ) =>
      row = @$( "tr.term[data-id='#{term.id}']" )
      row.find( 'td.target' ).html translations

  updateLangs: ->
    @$( '.titlebar h3' ).html @title
      source: @model.get( 'source' )?.toUpperCase()
      target: @model.get( 'target' )?.toUpperCase()

  openConcept: ( event ) ->
    row = $( event.target ).closest 'tr.term'
    if path = row.find( 'a[href]' ).attr( 'href' )[1..]
      Backbone.history.navigate path, trigger: true
    event.preventDefault()
    event.stopPropagation()

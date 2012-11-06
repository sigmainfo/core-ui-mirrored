#= require environment
#= require views/composite_view
#= require templates/layout/section

class Coreon.Views.Layout.SectionView extends Coreon.Views.CompositeView

  layout: Coreon.Templates["layout/section"]

  events: {}

  sectionTitle: ""

  delegateEvents: ->
    super
    @$el.on "click.toggle_#{@cid}", ".section-toggle", @toggle

  undelegateEvents: ->
    super
    @$el.off ".toggle_#{@cid}"

  render: ->
    @$el.html @layout
      title: _(@).result "sectionTitle"
      collapsed: @options.collapsed
    super
    
  toggle: (event) ->
    toggle = $(event.target)
    toggle.siblings(".section-toggle").andSelf().toggleClass "collapsed"
    toggle.siblings(".section").slideToggle()
    event.stopPropagation()

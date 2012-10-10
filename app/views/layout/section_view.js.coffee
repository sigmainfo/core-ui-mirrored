#= require environment
#= require views/composite_view
#= require templates/layout/section

class Coreon.Views.Layout.SectionView extends Coreon.Views.CompositeView

  sectionTitle: ""

  layout: Coreon.Templates["layout/section"]

  events:
    "click .section-toggle": "toggle"

  render: ->
    @$el.html @layout title: _(@).result "sectionTitle"
    super
    
  toggle: ->
    @$(".section-toggle").toggleClass "collapsed"
    @$(".section").slideToggle()
    @

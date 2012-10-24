#= require environment
#= require views/layout/section_view
#= require views/terms/term_view

class Coreon.Views.Terms.LanguageView extends Coreon.Views.Layout.SectionView

  className: "language"

  sectionTitle: -> @options.lang

  initialize: ->
    super
    @$el.addClass @options.lang

  render: ->
    super
    for term in @options.terms
      @append ".section", new Coreon.Views.Terms.TermView term: term
    view.render() for view in @subviews
    @

#= require environment
#= require views/composite_view
#= require templates/terms/term

class Coreon.Views.Terms.TermView extends Coreon.Views.CompositeView

  className: "term"

  template: Coreon.Templates["terms/term"]

  render: ->
    @$el.html @template value: @options.term.value
    super

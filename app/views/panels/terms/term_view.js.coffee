#= require environment
#= require helpers/can
#= require helpers/render
#= require templates/terms/_term
#= require templates/concepts/_info

class Coreon.Views.Panels.Terms.TermView extends Backbone.View

  tagName: 'li'

  className: 'term'

  template: Coreon.Templates['terms/term']

  render: ->
    @$el.html @template term: @model
    @
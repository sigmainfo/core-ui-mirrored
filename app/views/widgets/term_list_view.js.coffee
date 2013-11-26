#= require environment
#= require templates/widgets/term_list

class Coreon.Views.Widgets.TermListView extends Backbone.View

  id: 'coreon-term-list'

  className: 'widget'

  markup: Coreon.Templates['widgets/term_list']

  initialize: ->
    @renderMarkup()

  renderMarkup: ->
    @$el.html @markup()

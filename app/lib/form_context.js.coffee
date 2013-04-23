#= require environment

class Coreon.Lib.FormContext

  template: -> ""

  constructor: (context = {}, @_block = ->) ->
    @context = {}
    @context[key] = value for key, value of context
    @context.form = @

  render: ->
    @template @context

  yield: ->
    @_block.call @context

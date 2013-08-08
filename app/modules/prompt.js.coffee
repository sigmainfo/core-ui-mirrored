#= require environment

Coreon.Modules.Prompt =

  prompt: (widget) ->
    modal = $("#coreon-modal")
    modal.empty()
    @_prompt?.remove()
    if @_prompt = widget
      modal.append widget.render().$el

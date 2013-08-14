#= require environment

prompt = null

Coreon.Modules.Prompt =

  prompt: (widget) ->
    prompt?.remove()
    modal = $("#coreon-modal").empty()
    if prompt = widget
      modal.append widget.render().$el

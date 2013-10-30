#= require environment

prompt = null

Coreon.Modules.Prompt =
  
  unprompt: ->
    prompt?.remove()
    $("#coreon-modal").empty()
    
  prompt: (widget) ->
    modal = @unprompt()
    if prompt = widget
      modal.append widget.render().$el

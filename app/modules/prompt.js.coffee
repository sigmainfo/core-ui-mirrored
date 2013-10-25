#= require environment

prompt = null

Coreon.Modules.Prompt =
  
  modal: ->
    $("#coreon-modal")
  
  unprompt: ->
    prompt?.remove()
    @modal().empty()
    
  prompt: (widget) ->
    modal = @unprompt()
    if prompt = widget
      modal.append widget.render().$el

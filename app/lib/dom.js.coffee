#= require environment

$.fn.extend
  isOnScreen: ->
    element = this[0]
    top = element.getBoundingClientRect().top
    rect = undefined
    el = element.parentNode
    while el != document.body
      rect = el.getBoundingClientRect()
      if top <= rect.bottom == false
        return false
      el = el.parentNode

    top <= document.documentElement.clientHeight-element.offsetHeight

$.fn.extend
  scrollToReveal: ->
    $('html, body').animate({scrollTop: this.offset().top - $(window).height() + $('#coreon-filters').height()+$('#coreon-header').height()+(this.height()*2)}, 400);
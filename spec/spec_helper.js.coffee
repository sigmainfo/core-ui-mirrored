#= require jquery
#= require jquery.simulate
#= require sinon
#= require sinon-chai
#= require chai-jquery

jQuery.fx.off = true

before ->
  @_originalSession = localStorage.getItem Coreon.Models.Session::options.sessionId if Coreon.Models.Session?

after ->
  localStorage.setItem Coreon.Models.Session::options.sessionId, @_originalSession if @_originalSession?

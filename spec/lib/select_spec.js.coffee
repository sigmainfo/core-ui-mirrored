#= require spec_helper
#= require lib/select
    
describe 'Coreon.Lib.Select', ->
  
  beforeEach ->
    @select = $('<select>')
      
    @subject = new Coreon.Lib.Select @select
  
  it "is a Backbone view", ->
    @subject.should.be.an.instanceof Backbone.View
  
  describe 'changeTo()', ->
    
  describe 'showDropdown', ->
  
  
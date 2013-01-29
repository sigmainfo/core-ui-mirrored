#= require spec_helper
#= require helpers/text

describe "Coreon.Helpers.Text", ->

  beforeEach ->
    @helper = Coreon.Helpers.Text

  describe "shorten()", ->

    it "keeps short text unchanged", ->
      @helper.shorten("foo").should.eql "foo"
  
    it "shortens lengthy text", ->
      @helper.shorten("Lorem ipsum dolor sic").should.equal "Lorem ips…"

    it "allows 10 glyphs by default", ->
      @helper.shorten("1234567890").should.equal "1234567890"
      @helper.shorten("1234567890x").should.equal "123456789…"

    it "takes max length as second argument", ->
      @helper.shorten("12345", 5).should.equal "12345"
      @helper.shorten("12345x", 5).should.equal "1234…"
      

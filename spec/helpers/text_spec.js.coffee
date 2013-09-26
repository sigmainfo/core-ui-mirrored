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

  describe "wrap()", ->

    it "creates an array of strings", ->
      @helper.wrap("foo").should.eql [ "foo" ]

    it "word wraps lines after given length", ->
      @helper.wrap("lorem ipsum dolor sic amet", 12).should.eql [ "lorem ipsum", "dolor sic", "amet" ]
      
    it "defaults to 24 chars per line", ->
      @helper.wrap("lorem ipsum dolor sic amet").should.eql [ "lorem ipsum dolor sic", "amet" ]

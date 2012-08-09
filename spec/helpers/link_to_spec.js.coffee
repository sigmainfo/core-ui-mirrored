#= require spec_helper
#= require helpers/link_to

describe "Coreon.Helpers.link_to", ->

  beforeEach ->
    Backbone.history = new Backbone.History
    Backbone.history.start pushState: true

  afterEach ->
    Backbone.history.stop()

  it "creates link tag with label and href", ->
    link = $ Coreon.Helpers.link_to "http://foo.bar.baz"
    link.should.match "a"
    link.should.have.attr "href", "http://foo.bar.baz"
    link.should.have.text "http://foo.bar.baz"

  it "can define path url and label independently", ->
    link = $ Coreon.Helpers.link_to "Foo Bar Baz", "http://foo.bar.baz"
    link.should.have.text "Foo Bar Baz"

  it "prefixes relative urls", ->
    Coreon.application = options: root: "/my/root/prefix/"
    link = $ Coreon.Helpers.link_to "Foo Bar Baz", "foo/bar/baz"
    link.should.have.attr "href", "/my/root/prefix/foo/bar/baz"
    Coreon.application = null

  it "prepends slash when root is empty", ->
    Backbone.history.options.root = "/"
    link = $ Coreon.Helpers.link_to "Foo Bar Baz", "foo/bar/baz"
    link.should.have.attr "href", "/foo/bar/baz"

  it "accepts attributes hash", ->
    link = $ Coreon.Helpers.link_to "Foo", "foo", "class": "foo", "bar": true
    link.should.have.attr "class", "foo"
    link.should.have.attr "bar"

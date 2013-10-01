#= require spec_helper
#= require views/widgets/concept_map/render_strategy

describe "Coreon.Views.Widgets.ConceptMap.RenderStrategy", ->

  beforeEach ->
    @svg = $('<svg:g class="map">')
    @parent = d3.select @svg[0]
    sinon.stub d3.layout, "tree", => @layout =
      nodes: sinon.stub().returns []
    sinon.stub d3.svg, "diagonal", => @diagonal = {}
    @strategy = new Coreon.Views.Widgets.ConceptMap.RenderStrategy @parent, d3.layout.tree() 
    sinon.stub _, "defer", (@deferred) =>

  afterEach ->
    d3.layout.tree.restore()
    d3.svg.diagonal.restore()
    _.defer.restore()
  
  describe "constructor()", ->
  
    it "stores reference to parent selection", ->
      @strategy.should.have.deep.property "parent", @parent

    it "creates layout instance", ->
      @strategy.should.have.property "layout", @layout

    it "creates stencil for drawing edges", ->
      @strategy.should.have.property "diagonal", @diagonal

  describe "resize()", ->
    
    it "sets width and height values", ->
      @strategy.resize 320, 240
      @strategy.should.have.property "width", 320
      @strategy.should.have.property "height", 240

  describe "render()", ->

    beforeEach ->
      @tree =
        root: {}
        edges: {}

    it "renders nodes", ->
      @strategy.renderNodes = sinon.spy()
      @strategy.render @tree
      @strategy.renderNodes.should.have.been.calledOnce
      @strategy.renderNodes.should.have.been.calledWith @tree.root
      
    it "renders edges", ->
      @strategy.renderEdges = sinon.spy()
      @strategy.render @tree
      @strategy.renderEdges.should.have.been.calledOnce
      @strategy.renderEdges.should.have.been.calledWith @tree.edges

    it "defers update of layout", ->
      nodes = []
      edges = []
      @strategy.updateLayout = sinon.spy()
      @strategy.renderNodes = -> nodes
      @strategy.renderEdges = -> edges
      @strategy.render @tree
      @strategy.updateLayout.should.not.have.been.called
      _.defer.should.have.been.calledWith @strategy.updateLayout, nodes, edges

  describe "renderNodes()", ->

    beforeEach ->
      sinon.stub Coreon.Helpers, "repositoryPath"
      @parent.append("g")
        .attr("class", "concept-node")
        .datum(id: "remove")
      @parent.append("g")
        .attr("class", "concept-node")
        .datum(id: "update")
      @root =
        id: "root"
        children: [
          { id: "create" }
          { id: "update" }
        ]
      @layout.nodes.withArgs(@root).returns [
        { id: "root" }
        { id: "create" }
        { id: "update" }
      ]

    afterEach ->
      Coreon.Helpers.repositoryPath.restore()

    it "maps nodes to data", ->
      nodes = @strategy.renderNodes @root
      nodes.data().should.eql [
        { id: "root" }
        { id: "create" }
        { id: "update" }
      ]

    it "creates missing nodes including root node", ->
      @strategy.createNodes = sinon.spy()
      enter = @strategy.renderNodes(@root).enter()
      data = (node.__data__ for i, node of enter[0] when node.__data__?)
      data.should.eql [ { id: "root" }, { id: "create" } ]
      @strategy.createNodes.should.have.been.calledOnce
      @strategy.createNodes.should.have.been.calledWith enter

    it "deletes deprecated nodes", ->
      @strategy.deleteNodes = sinon.spy()
      exit = @strategy.renderNodes(@root).exit()
      data = (node.__data__ for i, node of exit[0] when node.__data__?)
      data.should.eql [ id: "remove" ]
      @strategy.deleteNodes.should.have.been.calledOnce
      @strategy.deleteNodes.should.have.been.calledWith exit

    it "updates all nodes", ->
      @strategy.updateNodes = sinon.spy()
      nodes = @strategy.renderNodes @root
      @strategy.updateNodes.should.have.been.calledOnce
      @strategy.updateNodes.should.have.been.calledWith nodes

  describe "createNodes()", ->

    beforeEach ->
      sinon.stub Coreon.Helpers, "repositoryPath"
      @enter = @parent
        .selectAll(".concept-node")
        .data([ id: "node1" ])
        .enter()

    afterEach ->
      Coreon.Helpers.repositoryPath.restore()

    it "appends concept node container", ->
      @strategy.createNodes @enter
      should.exist @parent.select("g.concept-node").node()

    it "renders link", ->
      Coreon.Helpers.repositoryPath.withArgs("concepts/node1").returns "/my-repo/concepts/node1"
      @strategy.createNodes @enter
      link = @parent.select(".concept-node a")
      should.exist link.node()
      link.attr("xlink:href").should.equal "/my-repo/concepts/node1"

    it "renders link to repository for root node", ->
      Coreon.Helpers.repositoryPath.withArgs().returns "/my-repo-123"
      @enter = @parent
        .selectAll(".concept-node")
        .data([ root: yes ])
        .enter()
      @strategy.createNodes @enter
      link = @parent.select(".concept-node a")
      should.exist link.node()
      link.attr("xlink:href").should.equal "/my-repo-123"

    it "renders dummy link for new concept", ->
      @enter = @parent
        .selectAll(".concept-node")
        .data([ id: null ])
        .enter()
      @strategy.createNodes @enter
      link = @parent.select(".concept-node a")
      should.exist link.node()
      link.attr("xlink:href").should.equal "javascript:void(0)"

    it "renders bullet", ->
      @strategy.createNodes @enter
      bullet = @parent.select(".concept-node a circle.bullet")
      should.exist bullet.node()

    it "renders empty label", ->
      @strategy.createNodes @enter
      label = @parent.select(".concept-node a text.label")
      should.exist label.node()

    it "inserts background", ->
      @strategy.createNodes @enter
      bg = @parent.select('.concept-node a rect.background')
      should.exist bg.node()

    it "renders title", ->
      @strategy.createNodes @enter
      title = @parent.select('.concept-node title')
      should.exist title.node()

    it "renders toggles", ->
      @strategy.createToggles = sinon.spy()
      nodes = @strategy.createNodes @enter
      @strategy.createToggles.should.have.been.calledTwice
      @strategy.createToggles.should.have.been.calledWith nodes, "toggle-children"
      @strategy.createToggles.should.have.been.calledWith nodes, "toggle-parents"

    it "returns selection of newly created nodes", ->
      nodes = @strategy.createNodes @enter
      nodes.node().should.equal @parent.select(".concept-node").node()

  describe "createToggles()", ->

    beforeEach ->
      @enter = @parent
        .selectAll(".concept-node")
        .data([ id: null ])
        .enter()
  
    it "creates container", ->
      toggles = @strategy.createToggles @enter, "toggle-nodes"
      should.exist toggles.node()
      toggles.attr("class").split(" ").should.include "toggle"
      toggles.attr("class").split(" ").should.include "toggle-nodes"

    it "renders background", ->
      toggles = @strategy.createToggles @enter, "toggle-nodes"
      background = toggles.select("rect.background")
      should.exist background.node()
      background.attr("width").should.equal "20"
      background.attr("height").should.equal "20"
      background.attr("x").should.equal "-10"
      background.attr("y").should.equal "-10"

    it "rendwers icon", ->
      toggles = @strategy.createToggles @enter, "toggle-nodes"
      icon = toggles.select("path.icon")
      should.exist icon.node()
      icon.attr("d").should.equal "M -3.5 -2 h 7 m 0 4 h -7"

  describe "deleteNodes()", ->
  
    it "removes nodes", ->
      exit = remove: sinon.spy()
      @strategy.deleteNodes exit
      exit.remove.should.have.been.calledOnce

  describe "updateNodes()", ->
    
    beforeEach ->
      @selection = @parent.append("g").attr("class", "concept-node")

    it "can be chained", ->
      nodes = @selection.data []
      @strategy.updateNodes(nodes).should.equal nodes

    it "classifies hits", ->
      nodes = @selection.data [
        hit: yes
      ]
      @strategy.updateNodes nodes
      nodes.attr("class").split(" ").should.include "hit"

    it "classifies new concepts", ->
      nodes = @selection.data [
        id: null
      ]
      @strategy.updateNodes nodes
      nodes.attr("class").split(" ").should.include "new"

    it "does not classify ordinary nodes", ->
      nodes = @selection.data [
        id: "node1"
        hit: no
      ]
      @strategy.updateNodes nodes
      classNames = nodes.attr("class").split(" ")
      classNames.should.not.include "hit"
      classNames.should.not.include "new"

    it "updates title", ->
      title = @selection.append("title")
      nodes = @selection.data [
        label: "node 123"
      ]
      @strategy.updateNodes nodes
      title.text().should.equal "node 123"

    it "updates bullet size depending on hit status", ->
      bullet = @selection.append("circle").attr("class", "bullet")
      nodes = @selection.data [
        hit: no
      ]
      @strategy.updateNodes nodes
      bullet.attr("r").should.equal "2.5"
      nodes = @selection.data [
        hit: yes
      ]
      @strategy.updateNodes nodes
      bullet.attr("r").should.equal "2.8"

    it "applies drop shadow depending on hit status", ->
      background = @selection.append("rect").attr("class", "background")
      nodes = @selection.data [
        hit: yes
      ]
      @strategy.updateNodes nodes
      background.attr("filter").should.equal "url(#coreon-drop-shadow-filter)"
      nodes = @selection.data [
        hit: no
      ]
      @strategy.updateNodes nodes
      should.not.exist background.attr("filter")

    it "rounds corners of root node", ->
      background = @selection.append("rect").attr("class", "background")
      nodes = @selection.data [
        root: yes
      ]
      @strategy.updateNodes nodes
      background.attr("rx").should.eql "5"
      nodes = @selection.data [
        root: no
      ]
      @strategy.updateNodes nodes
      should.not.exist background.attr("rx")

    it "hides toggle for parents on root nodes", ->
      toggle = @selection.append("g").attr("class", "toggle-parents")
      nodes = @selection.data [
        root: yes
      ]
      @strategy.updateNodes nodes
      toggle.attr("style").should.equal "display: none"
      nodes = @selection.data [
        root: no
      ]
      @strategy.updateNodes nodes
      should.equal toggle.attr("style"), null

    it "hides toggle for children on root nodes", ->
      toggle = @selection.append("g").attr("class", "toggle-children")
      nodes = @selection.data [
        leaf: yes
      ]
      @strategy.updateNodes nodes
      toggle.attr("style").should.equal "display: none"
      nodes = @selection.data [
        leaf: no
      ]
      @strategy.updateNodes nodes
      should.equal toggle.attr("style"), null

    it "classifies expanded toggle for children", ->
      toggle = @selection.append("g").attr("class", "toggle-children")
      nodes = @selection.data [
        leaf: no
        expandedOut: yes
      ]
      @strategy.updateNodes nodes
      toggle.attr("class").split(" ").should.include "expanded"
      nodes = @selection.data [
        leaf: no
        expandedOut: no
      ]
      @strategy.updateNodes nodes
      toggle.attr("class").split(" ").should.not.include "expanded"
      
    it "classifies expanded toggle for parents", ->
      toggle = @selection.append("g").attr("class", "toggle-parents")
      nodes = @selection.data [
        root: no
        expandedIn: yes
      ]
      @strategy.updateNodes nodes
      toggle.attr("class").split(" ").should.include "expanded"
      nodes = @selection.data [
        root: no
        expandedIn: no
      ]
      @strategy.updateNodes nodes
      toggle.attr("class").split(" ").should.not.include "expanded"


  describe "renderEdges()", ->

    beforeEach ->
      source = id: "source"
      remove = id: "remove"
      update = id: "update"
      create = id: "create"
      @parent.append("g")
        .attr("class", "concept-edge")
        .datum(
          source: source
          target: remove
        )
      @parent.append("g")
        .attr("class", "concept-edge")
        .datum(
          source: source
          target: update
        )
      @edges = [
        { source: source, target: create } 
        { source: source, target: update } 
      ]

    it "creates missing edges", ->
      @strategy.createEdges = sinon.spy()
      enter = @strategy.renderEdges(@edges).enter()
      data = (edge.__data__ for i, edge of enter[0] when edge.__data__?)
      data.should.eql [
        source: id: "source"
        target: id: "create" 
      ]
      @strategy.createEdges.should.have.been.calledOnce
      @strategy.createEdges.should.have.been.calledWith enter

    it "deletes deprecated edges", ->
      @strategy.deleteEdges = sinon.spy()
      exit = @strategy.renderEdges(@edges).exit()
      data = (edge.__data__ for i, edge of exit[0] when edge.__data__?)
      data.should.eql [
        source: id: "source"
        target: id: "remove" 
      ]
      @strategy.deleteEdges.should.have.been.calledOnce
      @strategy.deleteEdges.should.have.been.calledWith exit

    it "updates all edges", ->
      @strategy.updateEdges = sinon.spy()
      edges = @strategy.renderEdges @edges
      @strategy.updateEdges.should.have.been.calledOnce
      @strategy.updateEdges.should.have.been.calledWith edges

  describe "createEdges()", ->
  
    beforeEach ->
      @enter = @parent
        .selectAll(".concept-edge")
        .data([ source: {id: "parent"}, target: {id: "child"} ])
        .enter()

    it "inserts path", ->
      @strategy.createEdges @enter
      should.exist @parent.select("path.concept-edge").node()

    it "returns selection of newly created paths", ->
      paths = @strategy.createEdges @enter
      paths.node().should.equal @parent.select(".concept-edge").node()
      
  describe "deleteEdges()", ->
  
    it "removes paths", ->
      exit = remove: sinon.spy()
      @strategy.deleteEdges exit
      exit.remove.should.have.been.calledOnce

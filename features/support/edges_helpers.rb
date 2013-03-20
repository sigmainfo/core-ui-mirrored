module EdgesHelpers
  def collect_edges
    page.evaluate_script <<-JS
      $("#coreon-concept-map .concept-edge").map( function() {
        source = this.__data__.source.model.get("label");
        target = this.__data__.target.model.get("label");
        return source + " -> " + target;
      }).get();
    JS
  end
end

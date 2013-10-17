module EdgesHelpers
  def collect_edges
    page.evaluate_script <<-JS
      $("#coreon-concept-map .concept-edge").map( function() {
        source = this.__data__.source.label;
        target = this.__data__.target.label;
        return source + " -> " + target;
      }).get();
    JS
  end

  def collect_placeholder_edges
    page.evaluate_script <<-JS
      $("#coreon-concept-map .concept-edge")
        .filter( function() {
          this.__data__.target.type == "placeholder"
        })
        .map( function() {
          return "+[" + this.__data__.source.label + "]";
        }).get();
    JS
  end
end

class Api::Graph::TnodesController < ApplicationController

  before_filter :authenticate

  def search
    regexp = Regexp.new( Regexp.escape(params["search"]["query"]), Regexp::IGNORECASE )
    nodes = Api::Graph::TaxonomyNode.where(name: regexp).to_a
    nodes.each do |node|
      node.super_nodes.each do |snode|
        nodes << snode
      end
    end
    render json: {
      total: nodes.count,
      per_page: 30,
      current_page: 1,
      hits: nodes.map do |node|
        {
          score: 1.0 / ( Text::Levenshtein.distance(node.name, params["search"]["query"]) + 1 ),
          result: node
        }
      end
    }
  end.try(:sort) { |a, b| b[:score] <=> a[:score] }
end

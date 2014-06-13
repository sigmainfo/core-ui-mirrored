module Navigation
  def visit_concept_details_page(concept, params = {})
    path = "/#{current_repository.id}/concepts/#{concept['id']}"
    path << "?#{params.to_query}" unless params.empty?
    visit path
  end
end

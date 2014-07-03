module NavigationSteps
  include Spinach::DSL
  include Navigation

  step 'I visit the page of this concept' do
    visit_concept_details_page @concept
  end
end

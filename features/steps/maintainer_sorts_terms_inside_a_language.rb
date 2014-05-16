class Spinach::Features::MaintainerSortsTermsInsideALanguage < Spinach::FeatureSteps

  include AuthSteps
  include Api::Graph::Factory
  include Navigation
  include Selectors

  def language(id)
    page.find ".language.#{id.downcase}"
  end

  def create_term(value, options = {})
    options[:precedence] ||= 0
    @concept ||= create_concept
    create_concept_term @concept, {
      value: value,
      lang: 'en',
      properties: [ key: 'precedence', value: options[:precedence] ]
    }
  end

  def term_order
    within language_section(:en) do
      page.all('.term').map do |term|
        term.find('.value').text()
      end
    end
  end

  step 'I am logged in as a maintainer of the repository' do
    repository_user :maintainer
    login
  end

  step 'a concept with English terms "handgun" and "firearm" exists' do
    create_term 'handgun', precedence: 1
    create_term 'firearm', precedence: 2
  end

  step 'I visit the concept details page' do
    visit_concept_details_page @concept
  end

  step 'I see the terms in following order: "handgun", "firearm"' do
    expect(term_order).to eq(['handgun', 'firearm'])
  end

  step 'I see the terms in following order: "firearm", "handgun"' do
    expect(term_order).to eq(['firearm', 'handgun'])
  end

  step 'I toggle "EDIT MODE"' do
    click_on "Edit mode"
  end

  step 'I see a drag handler for each term' do
    within language(:en) do
      @terms = page.all('.term')
      @terms.each do |term|
        term.should have_css('.drag-handle')
      end
    end
  end
end

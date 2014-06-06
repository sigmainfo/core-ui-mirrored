module SearchSteps
  include Spinach::DSL

  def search_widget
    find '#coreon-search'
  end

  def search_for( query )
    within search_widget do
      fill_in 'coreon-search-query', with: query
      find('input[type="submit"]').click
    end
  end

  step 'I enter "poet" in the search field' do
    within search_widget do
      fill_in 'coreon-search-query', with: 'poet'
    end
  end

  step 'I enter "gun" in the search field' do
    within search_widget do
      fill_in 'coreon-search-query', with: 'gun'
    end
  end

  step 'I enter "ball" in the search field' do
    within search_widget do
      fill_in 'coreon-search-query', with: 'ball'
    end
  end

  step 'I enter "poe" in the search field' do
    within search_widget do
      fill_in 'coreon-search-query', with: 'poe'
    end
  end

  step 'I click the search button' do
    within search_widget do
      find('input[type="submit"]').click
    end
  end

  step 'I search for "panopticum"' do
    search_for 'panopticum'
  end

  step 'I search for "handgun"' do
    search_for 'handgun'
  end

  step 'I do a search for "ball"' do
    search_for 'ball'
  end

  step 'I search for "screen"' do
    search_for 'screen'
  end

  step 'I should be on the search result page' do
    current_path.should =~ %r|^/#{current_repository.id}/concepts/search|
  end

  step 'I should see the query "poet" within the navigation' do
    current_path.should =~ %r|/poet$|
  end
end

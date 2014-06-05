def has_class(name)
  "contains(concat(' ', normalize-space(@class), ' '), ' #{name.to_s} ')"
end

Capybara.add_selector(:widget) do
  xpath do |title|
    ".//*[#{has_class :widget} and .//h3/text() = '#{title}']"
  end
end

Capybara.add_selector(:panel) do
  xpath do |title|
    ".//*[#{has_class :panel} and .//h3/text() = '#{title}']"
  end
end

Capybara.add_selector(:concept_node) do
  xpath do |label|
    """
      .//*[
        #{has_class 'concept-node'}
        and
        .//*[
          #{has_class :label}
          and
          . = '#{label}'
        ]
      ]
    """
  end
end

Capybara.add_selector(:table_row) do
  xpath do |label|
    ".//tr/th[normalize-space(.)='#{label}']/.."
  end
end

Capybara.add_selector(:term) do
  xpath do |value|
    ".//li[#{has_class :term} and .//*[#{has_class :value} and .='#{value}']]"
  end
end

Capybara.add_selector(:confirmation_dialog) do
  xpath do
    ".//*[#{has_class :confirm} and .//*[#{has_class :ok}]]"
  end
end

module Selectors
  def concept_details
    find('#coreon-concepts .concept')
  end

  def concept_properties
    page.find('#coreon-concepts .concept>section>h3', text: 'PROPERTIES' ).find(:xpath, '..')
  end

  def concept_property(label)
    within concept_properties do
      page.find(:table_row, label.downcase)
    end
  end

  def concept_map
    page.find :panel, 'Concept Map'
  end

  def language_section(lang)
    page.find "section.language.#{lang}"
  end
end

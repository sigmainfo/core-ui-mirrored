def has_class( name )
  "contains( concat( ' ', normalize-space( @class ), ' ' ), ' #{ name.to_s } ' )"
end

Capybara.add_selector( :widget ) do
  xpath do |title|
    ".//*[ #{ has_class :widget } and .//h3/text() = '#{ title }' ]"
  end
end

Capybara.add_selector( :panel ) do
  xpath do |title|
    ".//*[ #{ has_class :panel } and .//h3/text() = '#{ title }' ]"
  end
end

Capybara.add_selector( :concept_node ) do
  xpath do |label|
    """
      .//*[
        #{ has_class 'concept-node' }
        and
        .//*[
          #{ has_class :label }
          and
          . = '#{ label }'
        ]
      ]
    """
  end
end

Capybara.add_selector(:table_row) do
  xpath do |label|
    ".//tr/th[normalize-space()='#{label}']/.."
  end
end

Capybara.add_selector(:term) do
  xpath do |value|
    """
      .//li[
        #{ has_class :term }
        and
        .//h4[
          #{ has_class :value }
          and
          normalize-space() = '#{ value }'
        ]
      ]
    """
  end
end

Capybara.add_selector(:form) do
  xpath do |submit|
    """
    .//form
      [
        .//button
          [
            @type = 'submit'
            and
            normalize-space() = '#{submit}'
          ]
      ]
    """
  end
end

Capybara.add_selector(:section) do
  xpath do |title|
    """
      .//section
        [
          .//*
            [
              translate( local-name(), '123456', '******' ) = 'h*'
              and
              normalize-space() = '#{title}'
            ]
        ]
    """
  end
end

Capybara.add_selector(:fieldset_with_legend) do
  xpath do |legend_text|
    """
      .//fieldset
        [
          .//legend
            [
              normalize-space() = '#{legend_text}'
            ]
        ]
    """
  end
end


module Selectors

  def concept_properties
    page.find('.concept>section>h3', text: 'PROPERTIES' ).find(:xpath, '..')
  end

  def concept_property(label)
    within concept_properties do
      page.find(:table_row, label.downcase)
    end
  end

  def fieldset_with(label, value = '')
    all_fields = page.all :field, label
    field = all_fields.select { |f| f.value == value }.first
    expect(field).to have_xpath('ancestor::fieldset')
    field.find :xpath, 'ancestor::fieldset'
  end
end

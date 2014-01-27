def has_class( name )
  "contains( concat( ' ', normalize-space( @class ), ' ' ), ' #{ name.to_s } ' )"
end

Capybara.add_selector( :widget ) do
  xpath do |title|
    ".//*[ #{ has_class :widget } and .//h4/text() = '#{ title }' ]"
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

Capybara.add_selector( :listing ) do
  xpath do |caption|
    ".//table[ preceding-sibling::h3 [text() = '#{ caption }' ] ]"
  end
end

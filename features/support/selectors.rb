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

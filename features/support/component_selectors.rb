module ComponentSelectors
  def panel(title)
    page.find('.panel>.titlebar>h3', text: title).find(:xpath, '../..')
  end

  def concept_map
    panel 'Concept Map'
  end
end

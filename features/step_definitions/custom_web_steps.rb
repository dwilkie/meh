Then /^I should see the alt text "([^\"]*)(?: within "([^"]*)")?"$/ do |alt_text, selector|
  xpath = "//img[@alt='#{alt_text}']"
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_xpath(xpath)
    else
      assert page.has_xpath?(xpath)
    end
  end
end


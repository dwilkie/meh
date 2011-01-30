Then /^(?:|I )should see the alt text "([^\"]*)"(?: within "([^"]*)")?$/ do |alt_text, selector|
  xpath = "//img[@alt='#{alt_text}']"
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_xpath(xpath)
    else
      assert page.has_xpath?(xpath)
    end
  end
end

Then /^(?:|I )should see a translation of "([^"]*)"(?: within "([^"]*)")?$/ do |text, selector|
  web_step = %{I should see "#{translate(text)}"}
  web_step << %{ within "#{selector}"} if selector
  Then web_step
end

Then /^(?:|I )should (not )?see (?:some|any)thing within "([^"]*)"$/ do |expectation, selector|
  expectation = "_not" if expectation
  if page.respond_to? :should
    page.send("should#{expectation}", have_css(selector))
  else
    expectation ? !assert(page.has_css?(selector)) : assert(page.has_css?(selector))
  end
end


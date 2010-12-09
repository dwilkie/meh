require 'spec_helper'

describe "partnerships/edit.html.haml" do
  before(:each) do
    @partnership = assign(:partnership, stub_model(Partnership))
  end

  it "renders the edit partnership form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => partnership_path(@partnership), :method => "post" do
    end
  end
end

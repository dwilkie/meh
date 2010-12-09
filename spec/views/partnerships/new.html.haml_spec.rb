require 'spec_helper'

describe "partnerships/new.html.haml" do
  before(:each) do
    assign(:partnership, stub_model(Partnership).as_new_record)
  end

  it "renders new partnership form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => partnerships_path, :method => "post" do
    end
  end
end
